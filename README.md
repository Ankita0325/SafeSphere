# 🛡️ SafeSphere

### *Protect. Prevent. Respond.*

SafeSphere is an AI-powered women safety platform that helps users stay protected before, during, and after emergencies. It combines voice-activated emergency detection, AI-based safe navigation, anonymous community reporting, and real-time emergency response into one intelligent safety ecosystem.

---

# 📄 Project Overview

SafeSphere is a smart women safety application designed to provide instant emergency assistance using AI, GPS, speech recognition, and community-powered safety intelligence.

The application continuously monitors for emergency voice keywords (with user permission), automatically triggers SOS mode, shares live location with trusted contacts, recommends safer routes, and builds a real-time heatmap of unsafe areas through anonymous incident reporting.

---

# 🧩 Abstract

SafeSphere addresses the problem that many women do not have enough time to manually call for help during dangerous situations.

Unlike traditional emergency apps that depend on pressing an SOS button, SafeSphere proactively detects distress using AI voice recognition, automatically activates emergency mode, alerts trusted contacts, and guides users toward safer locations.

The platform also creates a continuously updated Community Safety Map, helping future users avoid unsafe areas.

---

# ❗ Problem Statement

Women often face emergencies where unlocking a phone and manually calling for help is impossible.

### Key Issues

* Unable to press SOS during an attack
* Unsafe travel routes at night
* Lack of real-time crime awareness
* Limited community reporting systems
* Difficulty finding nearby emergency services
* Lack of legal guidance for domestic violence victims

### Impact

* Delayed emergency response
* Increased safety risks
* Poor awareness of dangerous areas
* Low reporting of harassment incidents
* Difficulty accessing immediate help

---

# 💡 Proposed Solution

SafeSphere provides an intelligent emergency response system that automatically reacts when danger is detected.

The application:

* Detects emergency voice keywords using AI
* Automatically activates SOS mode
* Plays a loud emergency siren
* Shares live GPS location
* Sends SOS SMS to trusted contacts
* Finds nearby police stations and hospitals
* Recommends AI-powered safe routes
* Builds a real-time safety heatmap
* Supports anonymous incident reporting
* Provides domestic violence legal assistance

---

# 🚀 Features

* 🎙️ AI Voice Keyword Detection
* 🚨 Automatic Emergency Mode
* 🔊 Loud Emergency Siren
* 📍 Live GPS Tracking
* 📩 Offline SOS via SMS
* 👨‍👩‍👧 Emergency Contact Alerts
* 🚔 Nearby Police Stations
* 🏥 Nearby Hospitals
* 🗺️ AI Safe Route Recommendation
* 🔥 Unsafe Area Heatmap
* 📢 Anonymous Incident Reporting
* 👥 Community Safety Map
* ⚖️ Domestic Violence Support
* 🤖 AI Safety Assistant

---

# 🏗️ System Architecture

User → Voice Monitoring → AI Keyword Detection → Emergency Mode → GPS Tracking → SOS SMS → Police & Hospital Search → AI Safe Route → Community Safety Map

---

# ⚙️ Tech Stack

### Frontend

* Flutter

### Backend

* FastAPI (Python)

### Database

* Firebase Firestore

### Maps & Navigation

* Google Maps SDK
* Google Directions API

### Artificial Intelligence

* Gemini API

### Speech Recognition

* Speech-to-Text API
* Flutter Speech Recognition

### Communication

* Twilio SMS API

### Location Services

* GPS
* Geolocator

---

# 📂 File Tree: SafeSphere

```text
├── 📁 backend
│   ├── 📁 app
│   │   ├── 📁 models
│   │   │   ├── 🐍 database.py
│   │   │   ├── 🐍 schemas.py
│   │   │   └── 🐍 __init__.py
│   │   │
│   │   ├── 📁 routes
│   │   │   ├── 🐍 auth.py
│   │   │   ├── 🐍 emergency.py
│   │   │   ├── 🐍 reports.py
│   │   │   ├── 🐍 analytics.py
│   │   │   ├── 🐍 admin.py
│   │   │   └── 🐍 routes_ai.py
│   │   │
│   │   ├── 📁 services
│   │   │   ├── 🐍 ai_service.py
│   │   │   ├── 🐍 firebase_service.py
│   │   │   ├── 🐍 route_service.py
│   │   │   ├── 🐍 safety_score_calculator.py
│   │   │   ├── 🐍 sms_service.py
│   │   │   └── 🐍 dataset_service.py
│   │   │
│   │   ├── 📁 utils
│   │   │   └── 🐍 config.py
│   │   │
│   │   ├── 🐍 main.py
│   │   └── 🐍 __init__.py
│   │
│   ├── 📄 requirements.txt
│   ├── 🐳 Dockerfile
│   └── 🐳 docker-compose.yml
│
├── 📁 frontend
│   ├── 📁 lib
│   │   ├── 📁 screen
│   │   │   ├── 📄 splash_screen.dart
│   │   │   ├── 📄 onboarding_screen.dart
│   │   │   ├── 📄 login_screen.dart
│   │   │   ├── 📄 register_screen.dart
│   │   │   ├── 📄 home_screen.dart
│   │   │   ├── 📄 emergency_screen.dart
│   │   │   ├── 📄 heatmap_screen.dart
│   │   │   ├── 📄 route_screen.dart
│   │   │   ├── 📄 community_screen.dart
│   │   │   ├── 📄 support_screen.dart
│   │   │   └── 📄 profile_screen.dart
│   │   │
│   │   ├── 📁 services
│   │   │   ├── 📄 api_service.dart
│   │   │   ├── 📄 auth_service.dart
│   │   │   ├── 📄 emergency_service.dart
│   │   │   ├── 📄 location_service.dart
│   │   │   ├── 📄 route_service.dart
│   │   │   ├── 📄 sms_service.dart
│   │   │   ├── 📄 flashlight_service.dart
│   │   │   └── 📄 voice_service.dart
│   │   │
│   │   ├── 📁 widgets
│   │   │   ├── 📄 emergency_button.dart
│   │   │   ├── 📄 bottom_nav_bar.dart
│   │   │   ├── 📄 custom_appbar.dart
│   │   │   └── 📄 loading_widget.dart
│   │   │
│   │   ├── 📁 models
│   │   │   ├── 📄 user_model.dart
│   │   │   ├── 📄 emergency_model.dart
│   │   │   └── 📄 route_model.dart
│   │   │
│   │   └── 📄 main.dart
│   │
│   ├── 📁 assets
│   │   └── 📁 images
│   │
│   └── 📄 pubspec.yaml
│
├── 📁 dataset
│   └── 📄 worldcities.xlsx
│
├── 📄 README.md
└── 📄 .gitignore
```

---

# 🧠 Core Modules

## 🎙️ AI Voice Detection

* Listens for emergency keywords (with permission)
* Detects:

  * Help
  * SOS
  * Save Me
  * Bachao
* Automatically activates Emergency Mode

---

## 🚨 Emergency Module

Automatically performs:

* Starts loud emergency siren
* Retrieves live GPS location
* Sends SOS SMS
* Starts live location tracking
* Finds nearest police station
* Finds nearest hospital

---

## 📩 SOS Alert System

Emergency message contains:

* User Name
* Emergency Alert
* Live GPS Coordinates
* Google Maps Link
* Timestamp

Automatically sent to all trusted contacts.

---

## 🔥 Unsafe Area Heatmap

Community reports generate a live heatmap showing:

* Harassment
* Stalking
* Unsafe streets
* Poor lighting
* Suspicious activities

Color Scale

* 🟢 Safe
* 🟡 Medium Risk
* 🟠 High Risk
* 🔴 Very Dangerous

---

## 🗺️ AI Safe Route Recommendation

Uses A* Pathfinding Algorithm.

Considers:

* Crime reports
* Community ratings
* Police stations
* Hospitals
* Street lighting
* Heatmap intensity

Provides:

* Safest route
* Estimated time
* Distance
* Nearby safe locations

---

## 👥 Community Safety Map

Users anonymously report:

* Harassment
* Eve teasing
* Stalking
* Unsafe streets
* Poor lighting
* Suspicious persons

Every report updates the Safety Heatmap.

---

## ⚖️ Domestic Violence Support

Provides:

* Women's legal rights
* Domestic violence laws
* Emergency helplines
* Nearby NGOs
* Protection order guidance
* AI legal assistant

---

# 🔄 System Workflow

```
Microphone Permission
        │
        ▼
Voice Monitoring
        │
        ▼
Keyword Detected
("Help", "SOS", "Bachao")
        │
        ▼
🚨 Emergency Mode Activated
        │
        ▼
🔊 Loud Siren Starts
        │
 ┌──────┴─────────────┐
 ▼                    ▼
📍 Get Live GPS     📩 Send SOS SMS
 │                    │
 ▼                    ▼
👨‍👩‍👧 Notify Trusted Contacts
 │
 ▼
🚔 Find Nearby Police Station
 │
 ▼
🏥 Find Nearby Hospital
 │
 ▼
🗺️ AI Safe Route Recommendation
 │
 ▼
🔥 Update Community Heatmap
```

---

# 📊 Safety Risk Levels

| Safety Score | Level            | Indicator         |
| ------------ | ---------------- | ----------------- |
| 0–20         | 🟢 Safe          | Safe Zone         |
| 21–40        | 🟡 Low Risk      | Stay Alert        |
| 41–70        | 🟠 Moderate Risk | Avoid if Possible |
| 71–100       | 🔴 High Risk     | Dangerous Area    |

---

# 📈 Impact

## For Women

* Faster emergency response
* Hands-free SOS activation
* Safer travel routes
* Better awareness of dangerous areas
* Access to legal support

### Community

* Builds a crowd-sourced safety network
* Improves incident reporting
* Creates safer neighborhoods
* Encourages community participation

### Authorities

* Identifies crime hotspots
* Supports better resource allocation
* Improves public safety planning

---

# 💡 Innovation Highlights

* AI Voice-Activated Emergency Detection
* Automatic SOS Without Touching Phone
* Community-Powered Safety Heatmap
* AI Safe Route Recommendation
* Offline SMS Emergency Alerts
* Anonymous Incident Reporting
* Integrated Domestic Violence Support
* Real-Time Community Safety Network

---

# 🧠 Challenges Faced

* Reliable voice keyword detection in noisy environments
* Real-time GPS tracking with low battery usage
* Generating accurate safety scores
* Preventing fake incident reports
* Optimizing AI safe route calculations
* Ensuring user privacy and anonymous reporting
* Supporting offline emergency SMS functionality

---

# 📚 What We Learned

* Flutter cross-platform mobile development
* FastAPI backend architecture
* Firebase Firestore integration
* Google Maps SDK implementation
* GPS and geolocation services
* AI-powered speech recognition
* A* pathfinding algorithm for safe navigation
* Designing scalable real-time safety systems

---

# 🏁 Conclusion

SafeSphere is an AI-powered women safety platform that goes beyond traditional SOS applications by combining voice-activated emergency detection, intelligent route planning, anonymous community reporting, and real-time emergency response. By leveraging AI, GPS, and community-driven safety intelligence, SafeSphere empowers women to travel with greater confidence while enabling faster assistance during emergencies and contributing to safer communities for everyone.
