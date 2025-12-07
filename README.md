# AgriGuard Plus

> **Smart Agriculture Companion for Global Farmers**

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow_Lite-ML_Powered-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

AgriGuard Plus is an intelligent mobile application designed to empower farmers with cutting-edge technology. By leveraging Machine Learning and Cloud services, it provides instant crop disease detection, localized weather updates, and agricultural resources.

---

## System Architecture

The application follows a clean, modular architecture separating the UI, Business Logic, and Data layers.

```mermaid
graph TD
    User[Mobile User] -->|Interacts| UI[Flutter UI Layer]
    
    subgraph "Frontend Application"
        UI -->|State Assessment| Features
        
        subgraph Features
            Auth[Authentication]
            Dash[Dashboard]
            Pred[Prediction Module]
            Hist[History Tracker]
            Store[Store Locator]
        end
        
        Pred -->|Image Input| TFLite[TensorFlow Lite Model]
        TFLite -->|Inference| Result[Disease Result]
    end
    
    subgraph "Backend Services"
        Auth -->|Auth Requests| FirebaseAuth[Firebase Auth]
        Hist -->|Read/Write| Firestore[Cloud Firestore]
        Dash -->|Fetch Data| WeatherAPI[OpenWeatherMap API]
        Store -->|Geocoding| Gmaps[Google Maps API]
    end
    
    Result -->|Save| Firestore
```

---

## Key Features

### AI-Powered Analysis
- **Instant Detection**: Identify diseases like Bacterial Blight, Brown Spot, and Blast Disease.
- **Offline Capable**: Uses on-device TensorFlow Lite for rapid inference.
- **Recommendations**: Get immediate treatment advice and preventive measures.

### Smart Dashboard
- **Real-Time Weather**: Localized temperature and conditions via OpenWeatherMap.
- **Quick Scans**: One-tap access to camera or gallery for crop analysis.
- **Daily Tips**: Curated agricultural tips for better yield.

### Location Services
- **Nearby Stores**: Locate agricultural supply stores sorted by distance.
- **Interactive Maps**: Integrated Google Maps for easy navigation.

### Secure & Personalized
- **User Profiles**: Secure login and profile management via Firebase.
- **History Tracking**: Cloud-synced history of all your past analyses.

---

## Tech Stack

- **UI Framework**: Flutter (Dart)
- **State Management**: Stateful Widgets & Provider
- **Authentication**: Firebase Auth (Email/Password)
- **Database**: Cloud Firestore
- **Machine Learning**: TensorFlow Lite
- **External APIs**: 
  - OpenWeatherMap (Weather)
  - Google Maps (Location)

---

## Getting Started

### Prerequisites
- Flutter SDK (3.7+)
- Android Studio / VS Code
- Valid API Keys for Firebase, Google Maps, and OpenWeatherMap

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Aditya19110/agri_gurad.git
   cd agri_gurad
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory:
   ```env
   OPENWEATHER_API_KEY=your_openweather_api_key_here
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

---

## Project Structure

```
lib/
├── config/          # Themes and Constants
├── screens/         # UI Pages (Login, Home, Prediction)
├── services/        # Logic (Auth, Weather, History)
├── widgets/         # Reusable Components
├── main.dart        # Entry Point
└── routes.dart      # Navigation Map
```

---

## Contributors

| **Aditya Kulkarni** | **Vedika Lohiya** |
| :---: | :---: |
| [![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/Aditya19110) | [![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/vedikalohiya) |

---

<div align="center">
  <p>Made with ❤️ to support Sustainable Agriculture</p>
</div>
