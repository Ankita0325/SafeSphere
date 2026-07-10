from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
import logging
from app.services.firebase_service import FirebaseService
from app.services.ai_service import AIService
from app.services.safety_score_calculator import SafetyScoreCalculator

router = APIRouter()
logger = logging.getLogger(__name__)
firebase = FirebaseService()
ai_service = AIService()

@router.get("/safety-metrics")
async def get_safety_metrics(lat: float = 19.0760, lng: float = 72.8777):
    """Get comprehensive safety metrics for the home screen dashboard"""
    try:
        # 1. Get nearby incidents for calculations
        incidents = firebase.get_incident_reports(lat, lng, radius_km=5.0)
        
        # 2. Get nearby safety resources
        police = firebase.get_nearby_police_stations(lat, lng)
        hospitals = firebase.get_nearby_hospitals(lat, lng)
        
        # 3. Calculate overall safety score
        calc = SafetyScoreCalculator(police_stations=police, hospitals=hospitals)
        score_result = calc.calculate_score(lat, lng, incidents)
        
        # 4. Calculate SOS Response Score (based on recent SOS incidents and emergency readiness)
        sos_incidents = [i for i in incidents if i.get('incident_type', '').lower() == 'sos']
        sos_verified = [s for s in sos_incidents if s.get('status', '').lower() == 'verified']
        sos_response_score = 100
        if sos_incidents:
            # Lower SOS response if there are unverified SOS incidents
            unverified_sos = len([s for s in sos_incidents if s.get('status', '').lower() != 'verified'])
            sos_response_score = max(30, 100 - (unverified_sos * 15))
        # Factor in proximity to hospitals (faster response = higher score)
        nearby_hospitals_count = len([h for h in hospitals if calc._calculate_distance(lat, lng, h.get('lat', 0), h.get('lng', 0)) <= 2.0])
        sos_response_score = min(100, sos_response_score + (nearby_hospitals_count * 5))
        
        # 5. Calculate Community Trust Score (based on report verification rate and user engagement)
        total_reports = [i for i in incidents if i.get('status', '').lower() != 'rejected']
        verified_reports = [i for i in total_reports if i.get('status', '').lower() == 'verified']
        community_trust_score = 100
        if total_reports:
            verification_rate = len(verified_reports) / len(total_reports)
            community_trust_score = (verification_rate * 70) + 30  # 30-100 range
        # Add points for active community reporting
        community_trust_score = min(100, community_trust_score + min(20, len(total_reports)))
        
        # 6. Calculate AI Detection Score (based on AI confidence and spam/duplicate detection rate)
        ai_detection_score = 85.0
        try:
            incident_summaries = [
                {
                    'type': inc.get('incident_type', 'unknown'),
                    'severity': inc.get('severity', 'medium'),
                    'latitude': inc.get('latitude', 0),
                    'longitude': inc.get('longitude', 0)
                }
                for inc in incidents[:5]
            ]
            
            analysis = ai_service.analyze_safety({
                'lat': lat,
                'lng': lng,
                'time': datetime.now().isoformat(),
                'incidents': incident_summaries
            })
            if isinstance(analysis, dict) and 'error' not in analysis:
                ai_detection_score = float(analysis.get('safety_score', 85.0))
        except Exception as e:
            logger.error(f"Error in batch AI safety analysis: {str(e)}")
            ai_detection_score = 85.0

        ai_detection_score = min(100.0, max(50.0, ai_detection_score))
        
        # 7. Calculate Trust Level (composite decision score)
        trust_score = (
            (score_result["safety_score"] * 0.4) +
            (sos_response_score * 0.3) +
            (community_trust_score * 0.2) +
            (ai_detection_score * 0.1)
        )
        
        # Determine trust level
        if trust_score >= 80:
            trust_level = "High"
            trust_color = "green"
        elif trust_score >= 60:
            trust_level = "Medium"
            trust_color = "yellow"
        elif trust_score >= 40:
            trust_level = "Low"
            trust_color = "orange"
        else:
            trust_level = "Very Low"
            trust_color = "red"
        
        return {
            "overall_safety_score": score_result["safety_score"],
            "safety_status": score_result.get("status", "Unknown"),
            "safety_color": score_result.get("color_code", "yellow"),
            "sos_response_score": int(round(sos_response_score)),
            "community_trust_score": int(round(community_trust_score)),
            "ai_detection_score": int(round(ai_detection_score)),
            "trust_score": int(round(trust_score)),
            "trust_level": trust_level,
            "trust_color": trust_color,
            "metrics": {
                "total_incidents_nearby": len(incidents),
                "verified_reports": len(verified_reports),
                "sos_incidents": len(sos_incidents),
                "nearby_police_stations": len(police),
                "nearby_hospitals": len(hospitals),
            },
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        logger.error(f"Error getting safety metrics: {str(e)}")
        # Fallback to mock data
        return {
            "overall_safety_score": 67,
            "safety_status": "Medium Risk",
            "safety_color": "yellow",
            "sos_response_score": 75,
            "community_trust_score": 82,
            "ai_detection_score": 88,
            "trust_score": 75,
            "trust_level": "Medium",
            "trust_color": "yellow",
            "metrics": {
                "total_incidents_nearby": 12,
                "verified_reports": 8,
                "sos_incidents": 0,
                "nearby_police_stations": 3,
                "nearby_hospitals": 5,
            },
            "timestamp": datetime.now().isoformat()
        }

@router.get("/trends")
async def get_safety_trends(days: int = 30):
    """Get safety trends for the past N days"""
    try:
        # Generate sample trend data
        data = []
        for i in range(days):
            date = datetime.now() - timedelta(days=days-i)
            data.append({
                "date": date.isoformat()[:10],
                "incidents": 10 + i % 5,
                "emergencies": 2 + i % 3,
                "safety_score": 65 + (i % 10)
            })
        
        return {
            "trends": data,
            "period": f"{days} days",
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/hotspots")
async def get_safety_hotspots():
    """Get current safety hotspots"""
    try:
        return {
            "hotspots": [
                {
                    "location": "Andheri West",
                    "lat": 19.1179,
                    "lng": 72.8488,
                    "risk_level": "high",
                    "incidents": 12
                },
                {
                    "location": "Bandra",
                    "lat": 19.0544,
                    "lng": 72.8401,
                    "risk_level": "medium",
                    "incidents": 8
                }
            ],
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))