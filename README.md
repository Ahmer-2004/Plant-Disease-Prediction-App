<p align="center">
  <img src="assets/images/app_logo.png" alt="Plant Disease Prediction Logo" width="120" height="120">
</p>

<h1 align="center">🌿 Plant Disease Prediction</h1>

<p align="center">
  <strong>AI-powered mobile application for real-time plant disease detection, expert guidance, and weather monitoring</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/TensorFlow_Lite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white" alt="TFLite">
  <img src="https://img.shields.io/badge/Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Gemini">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Supported Diseases](#supported-diseases)
- [Model Details](#model-details)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Environment Variables](#environment-variables)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [API References](#api-references)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Overview

**Plant Disease Prediction** is a Flutter-based mobile application that leverages deep learning and generative AI to help farmers, gardeners, and agricultural professionals detect plant diseases from leaf images in real-time. The app uses an on-device MobileNetV3-Small TFLite model for instant offline inference, Google Gemini AI for expert chatbot guidance, and live weather data to provide actionable agricultural insights.

> **Why this matters:** Crop diseases cause an estimated 20–40% loss in global agricultural production annually. Early detection is critical, and this app puts that power directly in users' hands — no internet required for disease detection.

---

## Features

### 🔬 AI Disease Detection
- **On-device inference** using TensorFlow Lite — works offline
- **MobileNetV3-Small** architecture optimized for mobile (2.5 MB model)
- **20 disease classes** across 6 major crops
- **~95% validation accuracy** on the test dataset
- **Plant verification** using Google ML Kit to filter non-plant images before inference
- **Confidence scoring** with High / Medium / Low / Very Low thresholds
- **ImageNet normalization** (mean/std) matching the original training pipeline

### 📸 Image Capture
- **Real-time camera** — capture leaf images directly from the camera feed
- **Gallery upload** — select existing photos from device storage
- **Auto-preprocessing** — images are resized, normalized, and formatted automatically

### 🤖 AI Chatbot (Gemini)
- **Google Gemini 2.5 Flash** integration for natural-language expert advice
- **Context-aware responses** — the chatbot knows what disease was detected
- **Treatment recommendations** — symptoms, causes, and actionable remedies
- **General plant health Q&A** — ask anything about plant care

### 🌦️ Weather Monitoring
- **Real-time weather** via Open-Meteo API (no API key required)
- **16-day forecast** with hourly and daily breakdowns
- **Location-based** using device GPS + reverse geocoding via Nominatim
- **Weather details** — temperature, humidity, UV index, wind speed, precipitation, sunrise/sunset
- **Disease-weather correlation** — understand how weather conditions affect crop health

### 🎨 Premium UI/UX
- **Custom splash screen** with animated branding
- **Cupertino-style page transitions** for smooth navigation
- **Google Fonts (Poppins + Outfit)** for modern typography
- **Dark gradient themes** with glassmorphism elements
- **Provider-based state management** for reactive UI updates

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Application                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────────┐ │
│  │  Screens  │  │ Providers │  │      Config          │ │
│  ├──────────┤  ├──────────┤  ├───────────────────────┤ │
│  │ Home     │  │ Plant    │  │ ModelConfig           │ │
│  │ Camera   │←→│ Disease  │←→│  - Class Labels       │ │
│  │ Gallery  │  │ Provider │  │  - Thresholds         │ │
│  │ Chat     │  ├──────────┤  │  - Input Dimensions   │ │
│  │ Weather  │  │ Gemini   │  └───────────────────────┘ │
│  │ Detail   │  │ Provider │                             │
│  └──────────┘  ├──────────┤                             │
│                │ Weather  │                             │
│                │ Provider │                             │
│                └──────────┘                             │
│                     │                                   │
├─────────────────────┼───────────────────────────────────┤
│                     ▼                                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │              External Services                   │   │
│  ├──────────────┬──────────────┬───────────────────┤   │
│  │  TFLite      │  Gemini AI   │   Open-Meteo     │   │
│  │  (On-Device) │  (Cloud API) │   (Weather API)  │   │
│  └──────────────┴──────────────┴───────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Design Patterns
- **Provider Pattern** — State management using `ChangeNotifier` + `MultiProvider`
- **Repository Pattern** — Data fetching abstracted in provider classes
- **MVC-like Separation** — Screens (View), Providers (Controller), Config (Model)

---

## Tech Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Framework** | Flutter 3.9+ / Dart 3.9+ | Cross-platform mobile development |
| **ML Inference** | TensorFlow Lite (`tflite_flutter`) | On-device plant disease classification |
| **Image Validation** | Google ML Kit (`google_mlkit_image_labeling`) | Pre-filter non-plant images |
| **Generative AI** | Google Gemini 2.5 Flash (`google_generative_ai`) | AI chatbot for expert guidance |
| **Weather** | Open-Meteo API | Real-time weather data (free, no key) |
| **Geocoding** | Nominatim (OpenStreetMap) | Reverse geocoding for city names |
| **State Management** | Provider | Reactive state management |
| **Image Handling** | `image_picker`, `camera`, `image` | Capture and process images |
| **Networking** | `http`, `dio` | REST API calls |
| **Permissions** | `permission_handler`, `geolocator` | Camera, storage, and location access |
| **UI/Design** | Google Fonts, Lottie, Flutter SVG | Modern UI components |
| **Environment** | `flutter_dotenv` | Secure API key management |

---

## Supported Diseases

The model classifies **20 disease classes** across **6 crop types**:

| Crop | Diseases Detected | Status |
|------|-------------------|--------|
| 🌽 **Maize** | Common Rust | Disease |
| 🥔 **Potato** | Healthy | Healthy |
| 🌾 **Rice** | Leaf Blast, Neck Blast | Disease |
| 🍅 **Tomato** | Bacterial Spot, Early Blight, Late Blight, Leaf Mold, Septoria Leaf Spot, Spider Mites, Target Spot, Yellow Leaf Curl Virus, Mosaic Virus, Healthy | Disease / Healthy |
| 🎋 **Sugarcane** | Bacterial Blight, Red Rot, Healthy | Disease / Healthy |
| 🌾 **Wheat** | Septoria, Stripe Rust, Healthy | Disease / Healthy |

---

## Model Details

| Property | Value |
|----------|-------|
| **Architecture** | MobileNetV3-Small |
| **Framework** | PyTorch → ONNX → TensorFlow → TFLite |
| **Input Size** | 224 × 224 × 3 (RGB) |
| **Input Format** | Float32, ImageNet Normalized |
| **Normalization** | Mean: `[0.485, 0.456, 0.406]`, Std: `[0.229, 0.224, 0.225]` |
| **Output** | 20-class softmax probabilities |
| **Model Size** | ~2.5 MB (TFLite Float16) |
| **Validation Accuracy** | 95.97% |
| **Test Accuracy** | 94.50% |
| **Test F1 Score (Macro)** | 88.21% |
| **Test Precision (Macro)** | 89.51% |
| **Test Recall (Macro)** | 90.63% |
| **Training Epochs** | 20 |

### Inference Pipeline

```
Input Image → Resize (224×224) → RGB Float [0,1] → ImageNet Normalize → TFLite Inference → Softmax → Top-1 Prediction
```

---

## Getting Started

### Prerequisites

Ensure you have the following installed:

- **Flutter SDK** ≥ 3.9.0 — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** ≥ 3.9.0 (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** with API Level 21+ (Android 5.0+)
- **An Android device or emulator** (ARM-based recommended for TFLite)
- **Google Gemini API Key** — [Get one free](https://aistudio.google.com/apikey)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/plant-disease-prediction.git
   cd plant-disease-prediction
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables** (see [below](#environment-variables))

4. **Run the app**
   ```bash
   # On a connected Android device
   flutter run

   # On an Android emulator
   flutter run -d emulator-5554
   ```

### Environment Variables

This project uses a `.env` file for sensitive configuration. **Never commit the `.env` file** — it is already listed in `.gitignore`.

1. **Copy the template:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your API keys:**
   ```env
   # Google Gemini API Key (get yours at https://aistudio.google.com/apikey)
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```

3. **Verify:** The app will show a clear error in the chat screen if the key is missing or invalid.

> **Note:** The weather feature uses the [Open-Meteo API](https://open-meteo.com/) which is free and does not require an API key.

---

## Project Structure

```
plant-disease-prediction/
│
├── lib/                          # Main application source code
│   ├── main.dart                 # App entry point, theme, splash screen
│   ├── config/
│   │   └── model_config.dart     # ML model configuration & class labels
│   ├── providers/
│   │   ├── plant_disease_provider.dart  # TFLite inference engine
│   │   ├── gemini_provider.dart         # Gemini AI chatbot integration
│   │   └── weather_provider.dart        # Weather data & forecasts
│   └── screens/
│       ├── home_screen.dart             # Main dashboard
│       ├── camera_screen_mobile.dart    # Real-time camera capture
│       ├── gallery_screen_mobile.dart   # Gallery image selection
│       ├── chat_screen.dart             # AI chatbot interface
│       └── weather_detail_screen.dart   # Detailed weather view
│
├── assets/
│   ├── models/
│   │   └── model.tflite          # TFLite model (MobileNetV3-Small)
│   ├── images/
│   │   └── app_logo.png          # Application logo
│   └── animations/               # Lottie animation files
│
├── android/                      # Android-specific configuration
│   ├── app/
│   │   ├── build.gradle          # App-level Gradle config
│   │   └── src/main/
│   │       └── AndroidManifest.xml  # Permissions & app metadata
│   └── build.gradle              # Project-level Gradle config
│
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore rules
├── pubspec.yaml                  # Flutter dependencies & assets
├── analysis_options.yaml         # Dart analyzer configuration
└── README.md                     # This file
```

---

## How It Works

### 1. Disease Detection Flow
```
User captures/selects image
        │
        ▼
Google ML Kit validates it's a plant image
        │
        ├── ❌ Not a plant → Show rejection message
        │
        ▼ ✅ Plant detected
Image preprocessed (resize → normalize → float32)
        │
        ▼
TFLite model runs inference (on-device, offline)
        │
        ▼
Softmax applied to logits → Top-1 class + confidence
        │
        ▼
Result displayed with confidence level & formatted name
```

### 2. Chatbot Flow
```
User sends question (optionally with disease context)
        │
        ▼
Context-aware prompt constructed
        │
        ▼
Gemini 2.5 Flash generates response
        │
        ▼
Response displayed in chat UI with timestamp
```

### 3. Weather Flow
```
App requests location permission
        │
        ▼
GPS coordinates obtained via Geolocator
        │
        ├── Reverse geocode → City name (Nominatim)
        │
        ▼
Open-Meteo API fetched with hourly + 16-day daily forecast
        │
        ▼
Parsed into WeatherData model → UI updated via Provider
```

---

## API References

| Service | Usage | Auth Required |
|---------|-------|---------------|
| **Google Gemini** | AI chatbot responses | ✅ API Key (`.env`) |
| **Open-Meteo** | Weather forecasts | ❌ Free, no key |
| **Nominatim (OSM)** | Reverse geocoding | ❌ Free, User-Agent header |
| **Google ML Kit** | Image labeling (on-device) | ❌ On-device, no key |
| **TensorFlow Lite** | Disease classification | ❌ On-device, no key |

---

## Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/your-feature`
3. **Commit** your changes: `git commit -m "Add your feature"`
4. **Push** to the branch: `git push origin feature/your-feature`
5. **Open** a Pull Request

### Development Guidelines

- Follow Dart/Flutter best practices and linting rules defined in `analysis_options.yaml`
- Use Provider pattern for state management
- Keep providers focused on single responsibilities
- Add comments for complex logic
- Test on physical Android devices when possible (for camera + TFLite GPU)

---

## License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- **[TensorFlow Lite](https://www.tensorflow.org/lite)** — On-device ML inference
- **[Google Gemini](https://ai.google.dev/)** — Generative AI for chatbot
- **[Flutter](https://flutter.dev/)** — Cross-platform UI framework
- **[Open-Meteo](https://open-meteo.com/)** — Free weather API
- **[OpenStreetMap / Nominatim](https://nominatim.org/)** — Reverse geocoding
- **[Google ML Kit](https://developers.google.com/ml-kit)** — Image labeling
- **[MobileNetV3](https://arxiv.org/abs/1905.02244)** — Efficient CNN architecture
- **[PlantVillage Dataset](https://github.com/spMohanty/PlantVillage-Dataset)** — Training data foundation

---

<p align="center">
  Made with ❤️ for Agriculture
</p>
