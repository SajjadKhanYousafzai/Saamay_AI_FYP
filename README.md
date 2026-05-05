# Saamay AI - Your Quran Companion

![Saamay AI](saamay_ai/assets/images/book.png)

## Project Description
Saamay AI is a comprehensive, AI-powered Quran recitation and memorization companion. Built as a Final Year Project (FYP), it leverages advanced speech-to-text machine learning models to actively listen to a user's recitation, detect mistakes, and provide real-time audio corrections using authentic Ayah recitations.

## 🚀 Key Features
- **Memorization Mode (Hifz):** Select specific Surahs and Ayahs to memorize. The app tracks your recitation and plays correct audio pronunciations if you make mistakes.
- **Retain Mode (Muraja'ah):** Test your retention through randomized Ayah quizzes. The app calculates your recitation accuracy score and tracks your historical performance.
- **AI-Powered Mistake Detection:** Utilizes OpenAI's Whisper model via a Python FastAPI backend to accurately transcribe Arabic recitation.
- **Real-Time Corrections:** Automatically fetches the exact corrected audio snippet for the specific Ayah where the user faltered.
- **Deep Linking Auth:** Seamless Supabase authentication with custom URL schemes allowing login, signup, and password resets directly via email deep links.
- **Progress Tracking:** Tracks recitation history, success rates, and memorized verses across devices.

## 📱 Download & Install (APK)
You can directly install the app on your Android device! 
📥 **[Download Saamay AI APK](app-release.apk)**

*(Note to developer: After running `flutter build apk --release`, place the `app-release.apk` file in the root folder of this repository so the link above works.)*

## 🛠 High-Level Architecture / Tech Stack
- **Front-end:** Flutter (Dart) for cross-platform iOS and Android support.
- **Back-end:** Python (FastAPI) deployed on Modal for high-performance serverless AI inference.
- **Machine Learning:** OpenAI Whisper for Arabic Speech-to-Text.
- **Database & Auth:** Supabase (PostgreSQL, Authentication with Deep Linking).
- **Audio Processing:** EveryAyah API for reference recitation.

## 💻 Setup & Run Instructions
### Prerequisites
- Flutter SDK installed
- Supabase account and project
- Python 3.10+ (for backend)

### 1. Clone the repository
```bash
git clone https://github.com/SajjadKhanYousafzai/Saamay_AI_FYP.git
cd Saamay_AI_FYP
```

### 2. Setup the Flutter App
```bash
cd saamay_ai
flutter pub get
```
*Note: Ensure you have populated your `lib/config/env_config.dart` with your Supabase URL and Anon Key.*

```bash
flutter run
```

### 3. Setup the AI Backend
```bash
cd saamay_backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```
*Or deploy to Modal using `modal deploy app.main`.*
