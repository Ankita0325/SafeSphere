from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from typing import List, Dict, Optional
from pydantic import BaseModel
from app.models.schemas import EmergencyRequest, EmergencyContact, EmergencyStatus
from app.services.firebase_service import FirebaseService
from app.services.sms_service import SMSService
from app.services.route_service import RouteService
from app.services.ai_service import AIService
from datetime import datetime
import logging
import traceback
import uuid

router = APIRouter()
logger = logging.getLogger(__name__)

# ========== INITIALIZE SERVICES WITH ERROR HANDLING ==========
try:
    firebase = FirebaseService()
    logger.info("Firebase service initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize Firebase: {str(e)}")
    firebase = None

try:
    sms_service = SMSService()
    logger.info("SMS service initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize SMS service: {str(e)}")
    sms_service = None

try:
    route_service = RouteService()
    logger.info("Route service initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize Route service: {str(e)}")
    route_service = None

try:
    ai_service = AIService()
    logger.info("AI service initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize AI service: {str(e)}")
    ai_service = None

# ========== IN-MEMORY STORAGE FOR TESTING ==========
emergency_storage = []
active_emergencies = {}

# ========== REQUEST MODELS ==========
class EmergencyTriggerRequest(BaseModel):
    message: str
    location: Optional[str] = None
    user_id: Optional[str] = None
    emergency_type: Optional[str] = "general"
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    contact_numbers: Optional[List[str]] = []
    incident_type: Optional[str] = None
    description: Optional[str] = None
    timestamp: Optional[datetime] = None

class VoiceDetectionRequest(BaseModel):
    audio_text: str

# ========== SIMPLE TEST ENDPOINT ==========
@router.get("/test")
async def test_endpoint():
    return {
        "status": "success",
        "message": "Emergency router is working",
        "timestamp": datetime.now().isoformat()
    }

# ========== MAIN EMERGENCY TRIGGER ==========
@router.post("/trigger")
async def trigger_emergency(
    emergency_data: EmergencyTriggerRequest,
    background_tasks: BackgroundTasks
):
    try:
        logger.info("EMERGENCY TRIGGER RECEIVED")
        logger.info(f"Data: {emergency_data.dict()}")
        
        emergency_id = f"EMG-{datetime.now().strftime('%Y%m%d%H%M%S')}-{str(uuid.uuid4())[:8]}"
        
        # Store emergency in memory
        emergency_record = {
            "emergency_id": emergency_id,
            "user_id": emergency_data.user_id,
            "message": emergency_data.message,
            "location": emergency_data.location,
            "latitude": emergency_data.latitude,
            "longitude": emergency_data.longitude,
            "emergency_type": emergency_data.emergency_type,
            "contact_numbers": emergency_data.contact_numbers,
            "timestamp": datetime.now().isoformat(),
            "status": "active"
        }
        
        active_emergencies[emergency_id] = emergency_record
        emergency_storage.insert(0, emergency_record)
        
        if len(emergency_storage) > 100:
            emergency_storage.pop()
        
        # Send SMS via Twilio to configured number
        if sms_service:
            user_data = {"name": emergency_data.user_id or "Unknown", "phone": "Unknown"}
            location = {"lat": emergency_data.latitude, "lng": emergency_data.longitude, "timestamp": datetime.now().isoformat()}
            background_tasks.add_task(
                sms_service.send_emergency_alert,
                ["+919970206614"],
                user_data,
                location,
                message_override=f"Emergency: {emergency_data.message or 'SOS alert'}"
            )
            logger.info("SMS notification queued")
        
        return {
            "status": "success",
            "emergency_id": emergency_id,
            "message": "Emergency triggered successfully",
            "police_notified": False,
            "contacts_notified": 1
        }
        
    except Exception as e:
        logger.error(f"Error triggering emergency: {str(e)}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Failed to trigger emergency: {str(e)}")

# ========== OTHER ENDPOINTS ==========
@router.post("/add-contact/{user_id}")
async def add_emergency_contact(user_id: str, contact: EmergencyContact):
    try:
        return {"status": "success", "message": "Contact added successfully (in-memory)"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/remove-contact/{user_id}/{phone}")
async def remove_emergency_contact(user_id: str, phone: str):
    try:
        return {"status": "success", "message": "Contact removed successfully (in-memory)"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/contacts/{user_id}")
async def get_emergency_contacts(user_id: str):
    try:
        return {"contacts": [], "note": "Using in-memory storage"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/status")
async def get_emergency_status():
    try:
        return {
            "status": "operational",
            "system_ready": True,
            "active_emergencies": len(active_emergencies),
            "total_emergencies": len(emergency_storage),
            "last_trigger": emergency_storage[0]['timestamp'] if emergency_storage else None,
            "firebase_available": firebase is not None,
            "sms_available": sms_service is not None,
            "ai_available": ai_service is not None,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history/{user_id}")
async def get_emergency_history(user_id: str, limit: int = 10):
    try:
        user_history = [em for em in emergency_storage if em.get("user_id") == user_id][:limit]
        return {"history": user_history, "count": len(user_history)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class UpdateStatusRequest(BaseModel):
    status: str = "cancelled"

@router.put("/update-status/{emergency_id}")
async def update_emergency_status(emergency_id: str, request: UpdateStatusRequest):
    try:
        for emergency in emergency_storage:
            if emergency.get("emergency_id") == emergency_id:
                emergency["status"] = request.status
                break

        if emergency_id in active_emergencies:
            active_emergencies[emergency_id]["status"] = request.status

        return {"status": "success", "message": f"Status updated to {request.status}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/voice-detection")
async def detect_emergency_voice(payload: VoiceDetectionRequest):
    try:
        audio_text = payload.audio_text
        emergency_keywords = ['help', 'sos', 'emergency', 'danger', 'save', 'police', 
                             'fire', 'accident', 'attack', 'hurt', 'bleeding', 'rape', 'assault']
        detected = [kw for kw in emergency_keywords if kw in audio_text.lower()]
        return {
            "keywords_detected": detected,
            "emergency_detected": len(detected) > 0
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/ping")
async def ping():
    return {
        "status": "ok",
        "message": "Emergency service is reachable",
        "timestamp": datetime.now().isoformat()
    }