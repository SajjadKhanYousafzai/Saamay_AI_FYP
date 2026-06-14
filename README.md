
readme_content = '''<div align="center">

<!-- Animated Header -->
<img src="https://capsule-render.vercel.app/api?type=venom&color=0:0D7377,100:14919b&height=250&section=header&text=Saamay%20AI&fontSize=70&fontColor=ffffff&animation=fadeIn&fontAlignY=40&desc=Your%20AI-Powered%20Quran%20Companion&descAlignY=65&descSize=22&stroke=ffffff&strokeWidth=1" width="100%"/>

<!-- Status Badges -->
<p align="center">
  <img src="https://img.shields.io/badge/Status-Final%20Year%20Project-0D7377?style=for-the-badge&logo=graduation-cap&logoColor=white"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-14919b?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/AI-Whisper%20%7C%20FastAPI-FF6B35?style=for-the-badge&logo=openai&logoColor=white"/>
  <img src="https://img.shields.io/badge/License-MIT-FFD23F?style=for-the-badge&logo=opensourceinitiative&logoColor=black"/>
</p>

<!-- Typing Animation -->
<a href="https://git.io/typing-svg">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=24&duration=3000&pause=1000&color=0D7377&center=true&vCenter=true&width=800&lines=Real-time+Recitation+Correction;AI-Powered+Mistake+Detection;Tajweed+%26+Pronunciation+Assistance;Progress+Tracking+%26+Analytics" alt="Typing SVG"/>
</a>

</div>

---

## 📑 Table of Contents

<p align="center">
  <a href="#-demo-video"><img src="https://img.shields.io/badge/🎬_Demo_Video-FF6B35?style=flat-square"/></a>
  <a href="#-about"><img src="https://img.shields.io/badge/📖_About-0D7377?style=flat-square"/></a>
  <a href="#-key-features"><img src="https://img.shields.io/badge/✨_Features-14919b?style=flat-square"/></a>
  <a href="#-architecture"><img src="https://img.shields.io/badge/🏗️_Architecture-764BA2?style=flat-square"/></a>
  <a href="#-download"><img src="https://img.shields.io/badge/📥_Download-00C853?style=flat-square"/></a>
  <a href="#-setup"><img src="https://img.shields.io/badge/🚀_Setup-2196F3?style=flat-square"/></a>
</p>

---

## 🎬 Demo Video

<div align="center">

<!-- YouTube Video Preview with Play Button Overlay -->
<a href="https://www.youtube.com/watch?v=wuT6Q2u3H2g" target="_blank">
  <img src="https://img.youtube.com/vi/wuT6Q2u3H2g/maxresdefault.jpg" alt="Saamay AI - Demo Video" width="80%" style="border-radius: 12px; box-shadow: 0 8px 32px rgba(13, 115, 119, 0.3);"/>
  <br><br>
  <img src="https://img.shields.io/badge/▶️_Watch_Demo_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="Watch on YouTube"/>
</a>

<p><em>🎥 Click the thumbnail above to watch the full demo on YouTube</em></p>

</div>

---

## 📖 About

<div align="center">

> **Saamay AI** is a comprehensive, AI-powered Quran recitation and memorization companion designed to help users perfect their recitation through real-time intelligent feedback.

</div>

Built as a **Final Year Project (FYP)** at COMSATS University Islamabad, Saamay AI leverages advanced speech-to-text machine learning models to actively listen to a user's recitation, detect mistakes, and provide real-time audio corrections using authentic Ayah recitations.

| Aspect | Details |
|--------|---------|
| 🎓 **Institution** | COMSATS University Islamabad |
| 👥 **Team** | Sajjad Ali Shah, Ali Hassan Shahid |
| 🏷️ **Domain** | Software Engineering |
| 🎯 **Focus** | AI/ML · Mobile Development · Religious Tech |

---

## ✨ Key Features

<div align="center">

<table>
<tr>
<td width="50%" valign="top">

### 📿 Memorization Mode (Hifz)

Select specific Surahs and Ayahs to memorize. The app tracks your recitation and plays correct audio pronunciations if you make mistakes.

**Capabilities:**
- Surah & Ayah selection
- Real-time mistake detection
- Authentic audio corrections
- Progress persistence

</td>
<td width="50%" valign="top">

### 🧠 Retain Mode (Muraja'ah)

Test your retention through randomized Ayah quizzes. Calculates recitation accuracy scores and tracks historical performance.

**Capabilities:**
- Randomized Ayah quizzes
- Accuracy scoring
- Performance history
- Weak area identification

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 🤖 AI-Powered Mistake Detection

Utilizes **OpenAI's Whisper model** via a Python FastAPI backend to accurately transcribe Arabic recitation with high precision.

**Detects:**
- Missing words
- Incorrect pronunciations
- Repetition errors
- Tajweed violations

</td>
<td width="50%" valign="top">

### 🔊 Real-Time Corrections

Automatically fetches the exact corrected audio snippet for the specific Ayah where the user faltered, enabling instant learning.

**Sources:**
- EveryAyah API integration
- Authentic reciter audio
- Precise Ayah-level snippets
- Low-latency delivery

</td>
</tr>
</table>

### 🔐 Additional Features

<p>
  <img src="https://img.shields.io/badge/Deep_Linking_Auth-0D7377?style=for-the-badge&logo=supabase&logoColor=white"/>
  <img src="https://img.shields.io/badge/Progress_Tracking-14919b?style=for-the-badge&logo=chart-line&logoColor=white"/>
  <img src="https://img.shields.io/badge/Cross_Platform-FF6B35?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Serverless_Backend-00C853?style=for-the-badge&logo=modal&logoColor=white"/>
</p>

- **Deep Linking Auth**: Seamless Supabase authentication with custom URL schemes for login, signup, and password resets via email
- **Progress Tracking**: Tracks recitation history, success rates, and memorized verses across devices
- **Cross-Platform**: Flutter ensures native performance on both Android and iOS

</div>

---

## 🏗️ High-Level Architecture

<div align="center">

```
┌─────────────────────────────────────────────────────────────┐
│                    📱 FRONTEND (Flutter)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Hifz Mode  │  │ Muraja'ah    │  │  Progress    │      │
│  │   (Memorize) │  │   (Quiz)     │  │   Dashboard  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP/WebSocket
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              ⚡ BACKEND (FastAPI on Modal)                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  🎙️ Audio Upload  →  🤖 Whisper STT  →  ✅ Validation │   │
│  │         ↓                    ↓            ↓         │   │
│  │  ┌─────────────┐    ┌─────────────┐   ┌───────────┐ │   │
│  │  │   PyTorch   │    │  HuggingFace│   │  Text     │ │   │
│  │  │   Whisper   │    │ Transformers│   │  Compare  │ │   │
│  │  └─────────────┘    └─────────────┘   └───────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│  🗄️ Supabase │ │ 🎵 Every │ │ 📊 Analytics │
│  (Auth + DB) │ │  Ayah API│ │   Storage    │
└──────────────┘ └──────────┘ └──────────────┘
```

</div>

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Front-end** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white) | Cross-platform mobile UI |
| **Back-end** | ![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white) | High-performance API server |
| **ML/AI** | ![OpenAI](https://img.shields.io/badge/Whisper-412991?style=flat-square&logo=openai&logoColor=white) ![PyTorch](https://img.shields.io/badge/PyTorch-EE4C2C?style=flat-square&logo=pytorch&logoColor=white) | Arabic speech-to-text |
| **Database** | ![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=flat-square&logo=supabase&logoColor=white) | PostgreSQL + Auth + Deep Links |
| **Audio** | EveryAyah API | Reference recitation audio |
| **Deployment** | ![Modal](https://img.shields.io/badge/Modal-7B68EE?style=flat-square) | Serverless Python hosting |

---

## 📥 Download & Install

<div align="center">

<a href="https://github.com/SajjadKhanYousafzai/Saamay_AI_FYP/releases/latest/download/app-debug.apk">
  <img src="https://img.shields.io/badge/📥_Download_Saamay_AI_APK-0D7377?style=for-the-badge&logo=android&logoColor=white" height="40"/>
</a>

<p><em>Direct APK download for Android devices</em></p>

> ⚠️ **Note for Repository Owner**: Upload your <code>app-debug.apk</code> to the <strong>Releases</strong> section for this link to work.

</div>

---

## 🚀 Setup & Run Instructions

### Prerequisites

```
Flutter SDK  •  Supabase Account  •  Python 3.10+  •  Git
```

### Step 1: Clone the Repository

```bash
git clone https://github.com/SajjadKhanYousafzai/Saamay_AI_FYP.git
cd Saamay_AI_FYP
```

### Step 2: Setup the Flutter App

```bash
cd saamay_ai
flutter pub get
```

> 🔑 **Important**: Populate `lib/config/env_config.dart` with your Supabase URL and Anon Key before running.

```bash
flutter run
```

### Step 3: Setup the AI Backend

```bash
cd saamay_backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

**For production deployment:**
```bash
modal deploy app.main
```

---

## 📸 Screenshots

<div align="center">

| Memorization Mode | Quiz Mode | Progress Dashboard |
|:---:|:---:|:---:|
| <img src="saamay_ai/assets/images/book.png" width="200" alt="Memorization"/> | <img src="saamay_ai/assets/images/book.png" width="200" alt="Quiz Mode"/> | <img src="saamay_ai/assets/images/book.png" width="200" alt="Dashboard"/> |
| *Select Surahs & Ayahs* | *Test Your Retention* | *Track Performance* |

</div>

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

```bash
# 1. Fork the repository
# 2. Create your feature branch
git checkout -b feature/AmazingFeature

# 3. Commit your changes
git commit -m 'Add some AmazingFeature'

# 4. Push to the branch
git push origin feature/AmazingFeature

# 5. Open a Pull Request
```

---

## 📫 Connect With Us

<div align="center">

<a href="https://github.com/SajjadKhanYousafzai">
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"/>
</a>
<a href="mailto:sk4512949@gmail.com">
  <img src="https://img.shields.io/badge/Email-EA4335?style=for-the-badge&logo=gmail&logoColor=white"/>
</a>
<a href="https://www.youtube.com/watch?v=wuT6Q2u3H2g">
  <img src="https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white"/>
</a>

<p><em>Developed with ❤️ at COMSATS University Islamabad</em></p>

</div>

---

<div align="center">

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

<br>

### ⭐ Star this repository if you found it helpful!

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0D7377,100:14919b&height=120&section=footer&text=Saamay%20AI%20%7C%20Your%20Quran%20Companion&fontSize=18&fontColor=ffffff&animation=fadeIn" width="100%"/>

</div>

