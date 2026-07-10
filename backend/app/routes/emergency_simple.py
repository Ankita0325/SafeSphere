from fastapi import APIRouter, HTTPException, BackgroundTasks
from typing import Optional, List
from pydantic import BaseModel
from datetime import datetime
import logging
import uuid
import json

from app.services.sms_service import SMSService

router = APIRouter()
logger = logging.getLogger(__name__)
sms_service = SMSService()

# ========== MODELS ==========
class EmergencyTriggerRequest(BaseModel):
    message: Optional[str] = "SOS alert triggered"
    location: Optional[str] = None
    user_id: Optional[str] = None
    emergency_type: Optional[str] = "general"
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    contact_numbers: Optional[List[str]] = []
    description: Optional[str] = None

class EmergencyResponse(BaseModel):
    success: bool
    emergency_id: str
    message: str
    timestamp: str
    status: str

# ========== IN-MEMORY STORAGE ==========
emergency_history = []
active_emergencies = {}

# ========== ENDPOINTS ==========

@router.get("/ping")
async def ping():
    """Test if emergency route is working"""
    return {
        "status": "ok",
        "service": "emergency",
        "timestamp": datetime.now().isoformat()
    }

@router.post("/trigger", response_model=EmergencyResponse)
async def trigger_emergency(
    emergency_data: EmergencyTriggerRequest,
    background_tasks: BackgroundTasks
):
    """Trigger an emergency alert - Simplified version"""
    try:
        logger.info("🚨 EMERGENCY TRIGGERED")
        logger.info(f"Message: {emergency_data.message}")
        logger.info(f"User: {emergency_data.user_id}")
        logger.info(f"Location: {emergency_data.location}")

        # Generate unique ID
        emergency_id = f"EMG-{datetime.now().strftime('%Y%m%d%H%M%S')}-{uuid.uuid4().hex[:6].upper()}"

        # Create emergency record
        emergency_record = {
            "emergency_id": emergency_id,
            "user_id": emergency_data.user_id or "anonymous",
            "message": emergency_data.message or "SOS alert triggered",
            "location": emergency_data.location or "Unknown",
            "latitude": emergency_data.latitude,
            "longitude": emergency_data.longitude,
            "emergency_type": emergency_data.emergency_type,
            "contact_numbers": emergency_data.contact_numbers,
            "description": emergency_data.description,
            "timestamp": datetime.now().isoformat(),
            "status": "active"
        }

        # Store in memory
        active_emergencies[emergency_id] = emergency_record
        emergency_history.insert(0, emergency_record)

        # Keep only last 100 records
        if len(emergency_history) > 100:
            emergency_history.pop()

        # Send SMS via Twilio to the specified number
        background_tasks.add_task(
            send_emergency_sms,
            emergency_data.user_id or "anonymous",
            emergency_data.latitude or 0.0,
            emergency_data.longitude or 0.0,
            emergency_data.message or "SOS alert triggered"
        )

        logger.info(f"✅ Emergency {emergency_id} created successfully")

        return EmergencyResponse(
            success=True,
            emergency_id=emergency_id,
            message="Emergency triggered successfully",
            timestamp=datetime.now().isoformat(),
            status="active"
        )

    except Exception as e:
        logger.error(f"❌ Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/status")
async def get_status():
    """Get system status"""
    return {
        "status": "operational",
        "active_emergencies": len(active_emergencies),
        "total_emergencies": len(emergency_history),
        "last_trigger": emergency_history[0]["timestamp"] if emergency_history else None,
        "timestamp": datetime.now().isoformat()
    }

@router.get("/history")
async def get_history(limit: int = 10, user_id: Optional[str] = None):
    """Get emergency history"""
    try:
        if user_id:
            filtered = [e for e in emergency_history if e.get("user_id") == user_id]
            return {
                "emergencies": filtered[:limit],
                "total": len(filtered),
                "limit": limit
            }
        return {
            "emergencies": emergency_history[:limit],
            "total": len(emergency_history),
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class UpdateStatusRequest(BaseModel):
    status: str = "cancelled"

@router.put("/update-status/{emergency_id}")
async def update_emergency_status(emergency_id: str, request: UpdateStatusRequest):
    """Update emergency status"""
    try:
        for emergency in emergency_history:
            if emergency["emergency_id"] == emergency_id:
                emergency["status"] = request.status
                break

        if emergency_id in active_emergencies:
            active_emergencies[emergency_id]["status"] = request.status

        return {
            "success": True,
            "message": f"Emergency status updated to {request.status}",
            "emergency_id": emergency_id
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/resolve/{emergency_id}")
async def resolve_emergency(emergency_id: str):
    """Mark emergency as resolved"""
    try:
        for emergency in emergency_history:
            if emergency["emergency_id"] == emergency_id:
                emergency["status"] = "resolved"
                emergency["resolved_at"] = datetime.now().isoformat()

                if emergency_id in active_emergencies:
                    del active_emergencies[emergency_id]

                return {
                    "success": True,
                    "message": "Emergency resolved",
                    "emergency_id": emergency_id
                }

        raise HTTPException(status_code=404, detail="Emergency not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{emergency_id}")
async def delete_emergency(emergency_id: str):
    """Delete emergency record"""
    try:
        global emergency_history
        emergency_history = [e for e in emergency_history if e["emergency_id"] != emergency_id]

        if emergency_id in active_emergencies:
            del active_emergencies[emergency_id]

        return {
            "success": True,
            "message": "Emergency deleted"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ========== HELPER FUNCTIONS ==========
async def send_emergency_sms(user_id: str, lat: float, lng: float, message: str):
    """Send emergency SMS via Twilio to configured number."""
    user_data = {
        "name": user_id,
        "phone": "Unknown",
    }
    location = {
        "lat": lat,
        "lng": lng,
        "timestamp": datetime.now().isoformat(),
    }

    # Send to the configured emergency number
    result = sms_service.send_emergency_alert(
        ["+919970206614"],
        user_data,
        location,
        message_override=message
    )

    logger.info(f"SMS sent to +919970206614: {result}")
    return result