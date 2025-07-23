# 🌱 AgriGuard Plus

> Your Smart Agriculture Companion for Crop Disease Detection

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![TensorFlow Lite](https://img.shields.io/badge/TensorFlow%20Lite-ML%20Powered-green.svg)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

AgriGuard Plus is an intelligent mobile application that helps farmers and agricultural professionals detect crop diseases using advanced machine learning technology. Simply capture a photo of your crop, and get instant disease identification with treatment recommendations.

## 🚀 Features

### 📸 AI-Powered Disease Detection
- **Real-time Analysis**: Instant crop disease identification using TensorFlow Lite
- **High Accuracy**: Advanced machine learning model trained on agricultural datasets
- **Multiple Diseases**: Detects various crop diseases including Bacterial Blight, Brown Spot, Leaf Smut, Blast Disease, and Tungro
- **Confidence Scoring**: Shows prediction confidence levels with visual indicators

### 🎯 Smart Recommendations
- **Treatment Suggestions**: Disease-specific treatment and prevention recommendations
- **Expert Guidance**: Professional agricultural advice for each detected condition
- **Preventive Measures**: Tips to prevent future occurrences

### 📍 Location Services
- **Nearby Stores**: Find agricultural supply stores near your location
- **Google Maps Integration**: Interactive maps with store information
- **Store Details**: Contact information, ratings, and operating hours

### 📊 History & Tracking
- **Analysis History**: Keep track of all your crop disease analyses
- **Progress Monitoring**: Monitor crop health over time
- **Data Export**: Export analysis data for record keeping

### 🔐 User Management
- **Secure Authentication**: Firebase-powered user authentication
- **Profile Management**: Manage your agricultural profile and preferences
- **Data Sync**: Cloud synchronization across devices

## 📱 Screenshots

| Splash Screen | Login | Dashboard | Disease Analysis |
|:---:|:---:|:---:|:---:|
| ![Splash](screenshots/splash.png) | ![Login](screenshots/login.png) | ![Dashboard](screenshots/dashboard.png) | ![Analysis](screenshots/analysis.png) |

| History | Nearby Stores | Settings | Results |
|:---:|:---:|:---:|:---:|
| ![History](screenshots/history.png) | ![Stores](screenshots/stores.png) | ![Settings](screenshots/settings.png) | ![Results](screenshots/results.png) |

## 🛠️ Technologies Used

- **Frontend**: Flutter 3.7.2+
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Machine Learning**: TensorFlow Lite
- **Maps**: Google Maps Flutter
- **Animations**: Lottie Animations
- **Image Processing**: Image Picker, Image Processing
- **Location**: Geolocator, Permission Handler

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.7.2 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Platform-specific requirements:

#### For Android:
- Android SDK (API level 21 or higher)
- Android emulator or physical device

#### For iOS:
- macOS with Xcode 12.0 or higher
- iOS Simulator or physical iOS device
- CocoaPods

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Aditya19110/agri_gurad.git
cd agri_gurad
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication, Firestore Database, and Storage
3. Download the configuration files:
   - For Android: `google-services.json` → `android/app/`
   - For iOS: `GoogleService-Info.plist` → `ios/Runner/`

### 4. Google Maps API Setup

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API

3. Add the API key:
   - **Android**: Add to `android/app/src/main/AndroidManifest.xml`
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_API_KEY_HERE"/>
   ```
   - **iOS**: Add to `ios/Runner/AppDelegate.swift`
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   ```

### 5. TensorFlow Lite Model

1. Place your trained model file in `assets/tfmodel/agriguard_model.tflite`
2. Update the disease labels in `lib/screens/prediction.dart` to match your model

### 6. Run the Application

```bash
# Run on debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Build for release
flutter build apk --release
flutter build ios --release
```

## 📁 Project Structure

```
agri_gurad/
├── lib/
│   ├── config/
│   │   └── app_theme.dart          # App theme and styling
│   ├── screens/
│   │   ├── splash.dart             # Splash screen
│   │   ├── login_screen.dart       # User authentication
│   │   ├── registration.dart       # User registration
│   │   ├── home_page.dart          # Main dashboard
│   │   ├── prediction.dart         # Disease prediction
│   │   ├── history_screen.dart     # Analysis history
│   │   ├── nearby_store.dart       # Store locator
│   │   └── settings.dart           # App settings
│   ├── services/
│   │   └── auth_service.dart       # Authentication service
│   ├── widgets/
│   │   └── app_drawer.dart         # Navigation drawer
│   ├── main.dart                   # App entry point
│   └── routes.dart                 # App routing
├── assets/
│   ├── lottie/                     # Animation files
│   └── tfmodel/                    # ML model files
├── android/                        # Android-specific files
├── ios/                           # iOS-specific files
├── pubspec.yaml                   # Dependencies
└── README.md                      # This file
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Manual Testing Checklist

- [ ] User registration and login
- [ ] Image capture and selection
- [ ] Disease prediction accuracy
- [ ] Location services and maps
- [ ] Data persistence and sync
- [ ] Offline functionality

## 🚀 Deployment

### Android Deployment

1. **Generate Keystore**:
```bash
keytool -genkey -v -keystore ~/agriguard-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias agriguard
```

2. **Configure Signing**:
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=agriguard
storeFile=<path-to-keystore>
```

3. **Build Release APK**:
```bash
flutter build apk --release
```

### iOS Deployment

1. **Configure App Store Connect**
2. **Update iOS deployment target** (iOS 12.0+)
3. **Build for release**:
```bash
flutter build ios --release
```


## 🆘 Support

### Frequently Asked Questions

**Q: The app doesn't detect diseases accurately. What should I do?**
A: Ensure good lighting and clear images. The model works best with well-lit, focused photos of affected crop areas.

**Q: Location services aren't working.**
A: Check that location permissions are granted and GPS is enabled on your device.

**Q: How do I backup my analysis history?**
A: Enable data backup in Settings. Your data will be automatically synced to the cloud.


## 👨‍💻 Author

**Aditya Kulkarni**
- GitHub: [@Aditya19110](https://github.com/Aditya19110)
- Email: aditya.kulkarnicse@gmail.com
- LinkedIn: [Aditya Kulkarni](https://linkedin.com/in/aditya191103)

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) for the amazing framework
- [Firebase](https://firebase.google.com/) for backend services
- [TensorFlow](https://www.tensorflow.org/) for machine learning capabilities
- [OpenAI](https://openai.com/) for development assistance
- Agricultural research institutions for disease datasets
- The farming community for valuable feedback

---

<div align="center">
  <p>Made with ❤️ for farmers worldwide</p>
  <p>🌱 <strong>Growing Technology for Better Agriculture</strong> 🌱</p>
</div>
