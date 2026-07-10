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
│   │   │   ├── 🐍 __init__.py
│   │   │   ├── 🐍 database.py
│   │   │   └── 🐍 schemas.py
│   │   ├── 📁 routes
│   │   │   ├── 🐍 __init__.py
│   │   │   ├── 🐍 admin.py
│   │   │   ├── 🐍 analytics.py
│   │   │   ├── 🐍 auth.py
│   │   │   ├── 🐍 emergency.py
│   │   │   ├── 🐍 emergency_simple.py
│   │   │   ├── 🐍 reports.py
│   │   │   └── 🐍 routes_ai.py
│   │   ├── 📁 services
│   │   │   ├── 🐍 __init__.py
│   │   │   ├── 🐍 ai_service.py
│   │   │   ├── 🐍 firebase_service.py
│   │   │   ├── 🐍 route_service.py
│   │   │   ├── 🐍 safety_score_calculator.py
│   │   │   └── 🐍 sms_service.py
│   │   ├── 📁 utils
│   │   │   └── 🐍 config.py
│   │   ├── 🐍 __init__.py
│   │   └── 🐍 main.py
│   ├── 📁 logs
│   ├── ⚙️ .example.env
│   ├── 🐳 Dockerfile
│   ├── ⚙️ docker-compose.yml
│   ├── ⚙️ nginx.conf
│   ├── 📄 requirements.txt
│   ├── 📄 safesphere.db
│   └── 📄 women_safety.db
├── 📁 frontend
│   ├── 📁 .dart_tool
│   │   ├── 📁 dartpad
│   │   │   └── 📄 web_plugin_registrant.dart
│   │   ├── 📁 flutter_build
│   │   │   ├── 📁 fe113c3576f06a3fd8191b7be5574a8f
│   │   │   │   ├── 📄 app.dill
│   │   │   │   ├── 📄 gen_dart_plugin_registrant.stamp
│   │   │   │   └── 📄 gen_localizations.stamp
│   │   │   └── 📄 dart_plugin_registrant.dart
│   │   ├── 📁 hooks_runner
│   │   │   ├── 📁 objective_c
│   │   │   │   └── 📁 68c609493f
│   │   │   │       ├── ⚙️ .lock
│   │   │   │       └── 📄 hook.dill
│   │   │   └── 📁 shared
│   │   │       └── 📁 objective_c
│   │   │           └── ⚙️ .lock
│   │   ├── ⚙️ package_config.json
│   │   ├── ⚙️ package_graph.json
│   │   └── 📄 version
│   ├── 📁 android
│   │   ├── 📁 .gradle
│   │   │   ├── 📁 9.1.0
│   │   │   │   ├── 📁 checksums
│   │   │   │   │   ├── 📄 checksums.lock
│   │   │   │   │   ├── ⚙️ md5-checksums.bin
│   │   │   │   │   └── ⚙️ sha1-checksums.bin
│   │   │   │   ├── 📁 executionHistory
│   │   │   │   │   ├── ⚙️ executionHistory.bin
│   │   │   │   │   └── 📄 executionHistory.lock
│   │   │   │   ├── 📁 expanded
│   │   │   │   ├── 📁 fileChanges
│   │   │   │   │   └── ⚙️ last-build.bin
│   │   │   │   ├── 📁 fileHashes
│   │   │   │   │   ├── ⚙️ fileHashes.bin
│   │   │   │   │   ├── 📄 fileHashes.lock
│   │   │   │   │   └── ⚙️ resourceHashesCache.bin
│   │   │   │   ├── 📁 vcsMetadata
│   │   │   │   └── 📄 gc.properties
│   │   │   ├── 📁 buildOutputCleanup
│   │   │   │   ├── 📄 buildOutputCleanup.lock
│   │   │   │   ├── 📄 cache.properties
│   │   │   │   └── ⚙️ outputFiles.bin
│   │   │   ├── 📁 kotlin
│   │   │   │   └── 📁 errors
│   │   │   ├── 📁 noVersion
│   │   │   │   └── 📄 buildLogic.lock
│   │   │   ├── 📁 vcs-1
│   │   │   │   └── 📄 gc.properties
│   │   │   └── 📄 file-system.probe
│   │   ├── 📁 .kotlin
│   │   │   ├── 📁 errors
│   │   │   └── 📁 sessions
│   │   ├── 📁 app
│   │   │   ├── 📁 src
│   │   │   │   ├── 📁 debug
│   │   │   │   │   └── ⚙️ AndroidManifest.xml
│   │   │   │   ├── 📁 main
│   │   │   │   │   ├── 📁 java
│   │   │   │   │   │   └── 📁 io
│   │   │   │   │   │       └── 📁 flutter
│   │   │   │   │   │           └── 📁 plugins
│   │   │   │   │   │               └── ☕ GeneratedPluginRegistrant.java
│   │   │   │   │   ├── 📁 kotlin
│   │   │   │   │   │   └── 📁 com
│   │   │   │   │   │       ├── 📁 example
│   │   │   │   │   │       │   └── 📁 safesphere
│   │   │   │   │   │       │       └── ☕ MainActivity.kt
│   │   │   │   │   │       └── 📁 womensafety
│   │   │   │   │   │           └── 📁 women_safety_app
│   │   │   │   │   │               └── ☕ MainActivity.kt
│   │   │   │   │   ├── 📁 res
│   │   │   │   │   │   ├── 📁 drawable
│   │   │   │   │   │   │   └── ⚙️ launch_background.xml
│   │   │   │   │   │   ├── 📁 drawable-v21
│   │   │   │   │   │   │   └── ⚙️ launch_background.xml
│   │   │   │   │   │   ├── 📁 mipmap-hdpi
│   │   │   │   │   │   │   └── 🖼️ ic_launcher.png
│   │   │   │   │   │   ├── 📁 mipmap-mdpi
│   │   │   │   │   │   │   └── 🖼️ ic_launcher.png
│   │   │   │   │   │   ├── 📁 mipmap-xhdpi
│   │   │   │   │   │   │   └── 🖼️ ic_launcher.png
│   │   │   │   │   │   ├── 📁 mipmap-xxhdpi
│   │   │   │   │   │   │   └── 🖼️ ic_launcher.png
│   │   │   │   │   │   ├── 📁 mipmap-xxxhdpi
│   │   │   │   │   │   │   └── 🖼️ ic_launcher.png
│   │   │   │   │   │   ├── 📁 values
│   │   │   │   │   │   │   └── ⚙️ styles.xml
│   │   │   │   │   │   └── 📁 values-night
│   │   │   │   │   │       └── ⚙️ styles.xml
│   │   │   │   │   └── ⚙️ AndroidManifest.xml
│   │   │   │   └── 📁 profile
│   │   │   │       └── ⚙️ AndroidManifest.xml
│   │   │   ├── 📄 build.gradle.kts
│   │   │   └── ⚙️ google-services.json
│   │   ├── 📁 gradle
│   │   │   └── 📁 wrapper
│   │   │       ├── 📄 gradle-wrapper.jar
│   │   │       └── 📄 gradle-wrapper.properties
│   │   ├── ⚙️ .gitignore
│   │   ├── 📄 build.gradle.kts
│   │   ├── 📄 gradle.properties
│   │   ├── 📄 gradlew
│   │   ├── 📄 gradlew.bat
│   │   ├── 📄 local.properties
│   │   └── 📄 settings.gradle.kts
│   ├── 📁 assets
│   │   └── 📁 images
│   │       ├── 🖼️ onboarding_1.png
│   │       ├── 🖼️ onboarding_2.png
│   │       ├── 🖼️ onboarding_3.png
│   │       └── 🖼️ onboarding_4.png
│   ├── 📁 ios
│   │   ├── 📁 Flutter
│   │   │   ├── 📁 ephemeral
│   │   │   │   ├── 📁 Packages
│   │   │   │   │   ├── 📁 .packages
│   │   │   │   │   └── 📁 FlutterGeneratedPluginSwiftPackage
│   │   │   │   │       ├── 📁 Sources
│   │   │   │   │       │   └── 📁 FlutterGeneratedPluginSwiftPackage
│   │   │   │   │       │       └── 🍎 FlutterGeneratedPluginSwiftPackage.swift
│   │   │   │   │       └── 🍎 Package.swift
│   │   │   │   ├── 🐍 flutter_lldb_helper.py
│   │   │   │   ├── 📄 flutter_lldbinit
│   │   │   │   └── ⚙️ flutter_native_integration.env
│   │   │   ├── 📄 AppFrameworkInfo.plist
│   │   │   ├── 📄 Debug.xcconfig
│   │   │   ├── 📄 Generated.xcconfig
│   │   │   ├── 📄 Release.xcconfig
│   │   │   └── 📄 flutter_export_environment.sh
│   │   ├── 📁 Runner
│   │   │   ├── 📁 Assets.xcassets
│   │   │   │   ├── 📁 AppIcon.appiconset
│   │   │   │   │   ├── ⚙️ Contents.json
│   │   │   │   │   ├── 🖼️ Icon-App-1024x1024@1x.png
│   │   │   │   │   ├── 🖼️ Icon-App-20x20@1x.png
│   │   │   │   │   ├── 🖼️ Icon-App-20x20@2x.png
│   │   │   │   │   ├── 🖼️ Icon-App-20x20@3x.png
│   │   │   │   │   ├── 🖼️ Icon-App-29x29@1x.png
│   │   │   │   │   ├── 🖼️ Icon-App-29x29@2x.png
│   │   │   │   │   ├── 🖼️ Icon-App-29x29@3x.png
│   │   │   │   │   ├── 🖼️ Icon-App-40x40@1x.png
│   │   │   │   │   ├── 🖼️ Icon-App-40x40@2x.png
│   │   │   │   │   ├── 🖼️ Icon-App-40x40@3x.png
│   │   │   │   │   ├── 🖼️ Icon-App-60x60@2x.png
│   │   │   │   │   ├── 🖼️ Icon-App-60x60@3x.png
│   │   │   │   │   ├── 🖼️ Icon-App-76x76@1x.png
│   │   │   │   │   ├── 🖼️ Icon-App-76x76@2x.png
│   │   │   │   │   └── 🖼️ Icon-App-83.5x83.5@2x.png
│   │   │   │   └── 📁 LaunchImage.imageset
│   │   │   │       ├── ⚙️ Contents.json
│   │   │   │       ├── 🖼️ LaunchImage.png
│   │   │   │       ├── 🖼️ LaunchImage@2x.png
│   │   │   │       ├── 🖼️ LaunchImage@3x.png
│   │   │   │       └── 📝 README.md
│   │   │   ├── 📁 Base.lproj
│   │   │   │   ├── 📄 LaunchScreen.storyboard
│   │   │   │   └── 📄 Main.storyboard
│   │   │   ├── 🍎 AppDelegate.swift
│   │   │   ├── ⚡ GeneratedPluginRegistrant.h
│   │   │   ├── 📄 GeneratedPluginRegistrant.m
│   │   │   ├── 📄 Info.plist
│   │   │   ├── ⚡ Runner-Bridging-Header.h
│   │   │   └── 🍎 SceneDelegate.swift
│   │   ├── 📁 Runner.xcodeproj
│   │   │   ├── 📁 project.xcworkspace
│   │   │   │   ├── 📁 xcshareddata
│   │   │   │   │   ├── 📄 IDEWorkspaceChecks.plist
│   │   │   │   │   └── 📄 WorkspaceSettings.xcsettings
│   │   │   │   └── 📄 contents.xcworkspacedata
│   │   │   ├── 📁 xcshareddata
│   │   │   │   └── 📁 xcschemes
│   │   │   │       └── 📄 Runner.xcscheme
│   │   │   └── 📄 project.pbxproj
│   │   ├── 📁 Runner.xcworkspace
│   │   │   ├── 📁 xcshareddata
│   │   │   │   ├── 📄 IDEWorkspaceChecks.plist
│   │   │   │   └── 📄 WorkspaceSettings.xcsettings
│   │   │   └── 📄 contents.xcworkspacedata
│   │   ├── 📁 RunnerTests
│   │   │   └── 🍎 RunnerTests.swift
│   │   └── ⚙️ .gitignore
│   ├── 📁 lib
│   │   ├── 📁 models
│   │   │   ├── 📄 emergency_model.dart
│   │   │   ├── 📄 route_model.dart
│   │   │   └── 📄 user_model.dart
│   │   ├── 📁 screen
│   │   │   ├── 📄 community_screen.dart
│   │   │   ├── 📄 emergency_contacts_screen.dart
│   │   │   ├── 📄 emergency_history_screen.dart
│   │   │   ├── 📄 emergency_screen.dart
│   │   │   ├── 📄 heatmap_screen.dart
│   │   │   ├── 📄 home_screen.dart
│   │   │   ├── 📄 location_picker_screen.dart
│   │   │   ├── 📄 location_settings_screen.dart
│   │   │   ├── 📄 login_screen.dart
│   │   │   ├── 📄 my_profile_screen.dart
│   │   │   ├── 📄 notifications_screen.dart
│   │   │   ├── 📄 onboarding_screen.dart
│   │   │   ├── 📄 profile_screen.dart
│   │   │   ├── 📄 register_screen.dart
│   │   │   ├── 📄 route_screen.dart
│   │   │   ├── 📄 safe_maps_screen.dart
│   │   │   ├── 📄 splash_screen.dart
│   │   │   └── 📄 support_screen.dart
│   │   ├── 📁 services
│   │   │   ├── 📄 api_service.dart
│   │   │   ├── 📄 api_service_new.dart
│   │   │   ├── 📄 auth_service.dart
│   │   │   ├── 📄 emergency_service.dart
│   │   │   ├── 📄 flashlight_service.dart
│   │   │   ├── 📄 location_service.dart
│   │   │   ├── 📄 route_service.dart
│   │   │   ├── 📄 safety_score_service.dart
│   │   │   ├── 📄 sms_service.dart
│   │   │   └── 📄 voice_service.dart
│   │   ├── 📁 utils
│   │   │   ├── 📄 constants.dart
│   │   │   ├── 📄 env_config.dart
│   │   │   └── 📄 theme.dart
│   │   ├── 📁 widgets
│   │   │   ├── 📄 animated_bottom_nav_bar.dart
│   │   │   ├── 📄 bottom_nav_bar.dart
│   │   │   ├── 📄 custom_appbar.dart
│   │   │   ├── 📄 emergency_button.dart
│   │   │   └── 📄 loading_widget.dart
│   │   ├── 📄 firebase_options.dart
│   │   └── 📄 main.dart
│   ├── 📁 linux
│   │   ├── 📁 flutter
│   │   │   ├── 📁 ephemeral
│   │   │   │   └── 📁 .plugin_symlinks
│   │   │   │       ├── 📄 connectivity_plus
│   │   │   │       ├── 📄 device_info_plus
│   │   │   │       ├── 📄 file_selector_linux
│   │   │   │       ├── 📄 flutter_secure_storage_linux
│   │   │   │       ├── 📄 image_picker_linux
│   │   │   │       ├── 📄 jni
│   │   │   │       ├── 📄 path_provider_linux
│   │   │   │       ├── 📄 shared_preferences_linux
│   │   │   │       └── 📄 url_launcher_linux
│   │   │   ├── 📄 CMakeLists.txt
│   │   │   ├── ⚡ generated_plugin_registrant.cc
│   │   │   ├── ⚡ generated_plugin_registrant.h
│   │   │   └── 📄 generated_plugins.cmake
│   │   ├── 📁 runner
│   │   │   ├── 📄 CMakeLists.txt
│   │   │   ├── ⚡ main.cc
│   │   │   ├── ⚡ my_application.cc
│   │   │   └── ⚡ my_application.h
│   │   ├── ⚙️ .gitignore
│   │   └── 📄 CMakeLists.txt
│   ├── 📁 macos
│   │   ├── 📁 Flutter
│   │   │   ├── 📁 ephemeral
│   │   │   │   ├── 📁 Packages
│   │   │   │   │   ├── 📁 .packages
│   │   │   │   │   └── 📁 FlutterGeneratedPluginSwiftPackage
│   │   │   │   │       ├── 📁 Sources
│   │   │   │   │       │   └── 📁 FlutterGeneratedPluginSwiftPackage
│   │   │   │   │       │       └── 🍎 FlutterGeneratedPluginSwiftPackage.swift
│   │   │   │   │       └── 🍎 Package.swift
│   │   │   │   ├── 📄 Flutter-Generated.xcconfig
│   │   │   │   ├── 📄 flutter_export_environment.sh
│   │   │   │   └── ⚙️ flutter_native_integration.env
│   │   │   ├── 📄 Flutter-Debug.xcconfig
│   │   │   ├── 📄 Flutter-Release.xcconfig
│   │   │   └── 🍎 GeneratedPluginRegistrant.swift
│   │   ├── 📁 Runner
│   │   │   ├── 📁 Assets.xcassets
│   │   │   │   └── 📁 AppIcon.appiconset
│   │   │   │       ├── ⚙️ Contents.json
│   │   │   │       ├── 🖼️ app_icon_1024.png
│   │   │   │       ├── 🖼️ app_icon_128.png
│   │   │   │       ├── 🖼️ app_icon_16.png
│   │   │   │       ├── 🖼️ app_icon_256.png
│   │   │   │       ├── 🖼️ app_icon_32.png
│   │   │   │       ├── 🖼️ app_icon_512.png
│   │   │   │       └── 🖼️ app_icon_64.png
│   │   │   ├── 📁 Base.lproj
│   │   │   │   └── 📄 MainMenu.xib
│   │   │   ├── 📁 Configs
│   │   │   │   ├── 📄 AppInfo.xcconfig
│   │   │   │   ├── 📄 Debug.xcconfig
│   │   │   │   ├── 📄 Release.xcconfig
│   │   │   │   └── 📄 Warnings.xcconfig
│   │   │   ├── 🍎 AppDelegate.swift
│   │   │   ├── 📄 DebugProfile.entitlements
│   │   │   ├── 📄 Info.plist
│   │   │   ├── 🍎 MainFlutterWindow.swift
│   │   │   └── 📄 Release.entitlements
│   │   ├── 📁 Runner.xcodeproj
│   │   │   ├── 📁 project.xcworkspace
│   │   │   │   └── 📁 xcshareddata
│   │   │   │       └── 📄 IDEWorkspaceChecks.plist
│   │   │   ├── 📁 xcshareddata
│   │   │   │   └── 📁 xcschemes
│   │   │   │       └── 📄 Runner.xcscheme
│   │   │   └── 📄 project.pbxproj
│   │   ├── 📁 Runner.xcworkspace
│   │   │   ├── 📁 xcshareddata
│   │   │   │   └── 📄 IDEWorkspaceChecks.plist
│   │   │   └── 📄 contents.xcworkspacedata
│   │   ├── 📁 RunnerTests
│   │   │   └── 🍎 RunnerTests.swift
│   │   └── ⚙️ .gitignore
│   ├── 📁 test
│   │   └── 📄 widget_test.dart
│   ├── 📁 web
│   │   ├── 📁 icons
│   │   │   ├── 🖼️ Icon-192.png
│   │   │   ├── 🖼️ Icon-512.png
│   │   │   ├── 🖼️ Icon-maskable-192.png
│   │   │   └── 🖼️ Icon-maskable-512.png
│   │   ├── 🖼️ favicon.png
│   │   ├── 🌐 index.html
│   │   └── ⚙️ manifest.json
│   ├── 📁 windows
│   │   ├── 📁 flutter
│   │   │   ├── 📁 ephemeral
│   │   │   │   └── 📁 .plugin_symlinks
│   │   │   │       ├── 📄 cloud_firestore
│   │   │   │       ├── 📄 connectivity_plus
│   │   │   │       ├── 📄 device_info_plus
│   │   │   │       ├── 📄 file_selector_windows
│   │   │   │       ├── 📄 firebase_auth
│   │   │   │       ├── 📄 firebase_core
│   │   │   │       ├── 📄 firebase_storage
│   │   │   │       ├── 📄 flutter_secure_storage_windows
│   │   │   │       ├── 📄 geolocator_windows
│   │   │   │       ├── 📄 image_picker_windows
│   │   │   │       ├── 📄 jni
│   │   │   │       ├── 📄 path_provider_windows
│   │   │   │       ├── 📄 permission_handler_windows
│   │   │   │       ├── 📄 shared_preferences_windows
│   │   │   │       ├── 📄 speech_to_text_windows
│   │   │   │       └── 📄 url_launcher_windows
│   │   │   ├── 📄 CMakeLists.txt
│   │   │   ├── ⚡ generated_plugin_registrant.cc
│   │   │   ├── ⚡ generated_plugin_registrant.h
│   │   │   └── 📄 generated_plugins.cmake
│   │   ├── 📁 runner
│   │   │   ├── 📁 resources
│   │   │   │   └── 📄 app_icon.ico
│   │   │   ├── 📄 CMakeLists.txt
│   │   │   ├── 📄 Runner.rc
│   │   │   ├── ⚡ flutter_window.cpp
│   │   │   ├── ⚡ flutter_window.h
│   │   │   ├── ⚡ main.cpp
│   │   │   ├── ⚡ resource.h
│   │   │   ├── 📄 runner.exe.manifest
│   │   │   ├── ⚡ utils.cpp
│   │   │   ├── ⚡ utils.h
│   │   │   ├── ⚡ win32_window.cpp
│   │   │   └── ⚡ win32_window.h
│   │   ├── ⚙️ .gitignore
│   │   └── 📄 CMakeLists.txt
│   ├── ⚙️ .flutter-plugins-dependencies
│   ├── ⚙️ .gitignore
│   ├── ⚙️ .metadata
│   ├── ⚙️ analysis_options.yaml
│   ├── 📄 build_log.txt
│   ├── 📄 pubspec.lock
│   └── ⚙️ pubspec.yaml
├── ⚙️ .gitignore
└── 📝 README.md
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
