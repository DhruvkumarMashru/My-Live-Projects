# 🚀 My Projects — Dhruvkumar Mashru

> A curated collection of projects spanning **Machine Learning**, **Android Development**, **Flutter**, **.NET**, **Python**, **PHP**, and **Web** technologies.

---

## 📁 Repository Structure

```
my-projects/
├── agrocraft-ecommerce/          # PHP e-commerce platform for farm produce
├── bloodcall-android-app/        # Android blood donation emergency app
├── glaucoma-detection-ml/        # ML-based glaucoma detection system
├── fake-news-detection-ml/       # NLP-powered fake news classifier
├── plastic-waste-prediction/     # Plastic waste prediction web app
├── gesture-control/              # AI gesture-based system control
├── anomaly-detector/             # Python anomaly detection tool
├── store-management-flutter/     # Flutter stock/store management app
├── erp-governance-dotnet/        # .NET ERP governance platform
├── dk-sql-buddy/                 # Python SQL assistant tool
└── portfolio-website/            # Personal portfolio (HTML/CSS/JS)
```

---

## 🌾 1. Agrocraft — Farm Produce E-Commerce

**Folder:** `agrocraft-ecommerce/`  
**Tech Stack:** PHP · MySQL · HTML · CSS · JavaScript

A full-stack e-commerce portal connecting farmers directly with buyers and admins.

**Features:**
- 🧑‍🌾 Farmer Portal — list produce, manage orders
- 🛒 Buyer Portal — browse, cart, checkout
- 🛡️ Admin Panel — user management, approvals
- 🔐 Auth system with PHP sessions
- 📦 MySQL database (`AgroCraft.sql` included)

---

## 🩸 2. BloodCall — Android Blood Donation App

**Folder:** `bloodcall-android-app/`  
**Tech Stack:** Android (Java/Kotlin) · Firebase · Google Maps SDK · ZXing

An emergency blood donation coordination app using real-time Firebase and Google services.

**Features:**
- 🗺️ Real-time map of hospitals & blood donation events
- 🚨 Emergency blood alerts pushed to compatible blood types
- 📱 QR code check-in system for hospitals
- 💬 Community forum (questions & experiences)
- 🔔 Firebase Cloud Messaging notifications
- 🏆 Gamified donor recognition system

---

## 👁️ 3. Glaucoma Detection — ML System

**Folder:** `glaucoma-detection-ml/`  
**Tech Stack:** Python · TensorFlow/Keras · Flask · OpenCV

An ML system for early glaucoma detection from retinal images.

**Features:**
- 🧠 Deep learning model for retinal image classification
- 📊 Interactive dashboard (`Glaucoma_Detection_dashboard.html`)
- 🔍 Model comparison view (`Glaucoma_Detection_compare.html`)
- 🐳 Docker support for deployment
- 📋 REST API via Flask backend

**Quick Start:**
```bash
cd glaucoma-detection-ml
pip install -r requirements.txt
python run.py
```

---

## 📰 4. Fake News Detection — NLP Classifier

**Folder:** `fake-news-detection-ml/`  
**Tech Stack:** Python · scikit-learn / NLP · Flask · NLTK

An NLP-based machine learning pipeline to classify news articles as real or fake.

**Features:**
- 📝 Text preprocessing with NLTK
- 🤖 Trained ML model with multiple algorithm comparison
- 📊 Web dashboard for predictions (`Fake_News_Detection_dashboard.html`)
- 📁 Modular `src/` structure (data, models, config)

**Quick Start:**
```bash
cd fake-news-detection-ml
pip install -r requirements.txt
python run.py
```

---

## ♻️ 5. Plastic Waste Prediction

**Folder:** `plastic-waste-prediction/`  
**Tech Stack:** Python · HTML/CSS/JS · Flask

A web-based tool predicting plastic waste accumulation with visualisation.

**Features:**
- 📈 Prediction visualisations via interactive HTML pages
- 🌐 Web app interface (`Plastic_Waste_Prediction_index.html`)
- 📦 Modular webapp folder structure

---

## 🤚 6. Gesture Control — AI System Controller

**Folder:** `gesture-control/`  
**Tech Stack:** Python · OpenCV · MediaPipe · HTML/PHP

A gesture-based system that lets you control your computer (mouse, volume, brightness, keyboard) using hand gestures captured via webcam.

**Features:**
- 🖱️ Mouse control via hand gestures
- 🔊 Volume & 🔆 Brightness adjustment
- ⌨️ Virtual keyboard (HTML-based)
- 👁️ Face detection mode
- 📷 Real-time webcam feed processing

---

## 🔍 7. Anomaly Detector

**Folder:** `anomaly-detector/`  
**Tech Stack:** Python · Flask · scikit-learn

A Python tool for detecting anomalies in data using ML algorithms.

**Features:**
- 🐍 Flask web interface (`app.py`)
- 🧰 Utility helpers (`utils.py`)
- 🤖 Pre-trained model in `model/` directory
- 📊 Visualisation support

**Quick Start:**
```bash
cd anomaly-detector
pip install -r requirements.txt
python app.py
```

---

## 🏪 8. Store Management — Flutter App

**Folder:** `store-management-flutter/`  
**Tech Stack:** Flutter · Dart · Android / iOS / Web / Desktop

A cross-platform store/stock management application built with Flutter.

**Features:**
- 📦 Inventory & stock tracking
- 📱 Multi-platform: Android, iOS, Web, Windows, macOS, Linux
- 🎨 Modern UI with Flutter Material Design
- 📊 Stock reporting

**Quick Start:**
```bash
cd store-management-flutter
flutter pub get
flutter run
```

---

## 🏛️ 9. ERP Governance — .NET Platform

**Folder:** `erp-governance-dotnet/`  
**Tech Stack:** .NET · C# · ASP.NET Core · Clean Architecture

An enterprise ERP governance platform built with Clean Architecture principles.

**Features:**
- 🏗️ Clean Architecture: `Domain`, `Application`, `Infrastructure`, `Web` layers
- 🔐 Role-based access and governance controls
- 📄 Full SRS & documentation included
- ⚙️ Setup script for quick dev environment init

**Quick Start:**
```bash
cd erp-governance-dotnet
# See "Important For Setup Please Read this.md" for prerequisites
dotnet restore ErpGovernance.sln
dotnet run --project ErpGovernance.Web
```

---

## 🗄️ 10. DK SQL Buddy — Python SQL Assistant

**Folder:** `dk-sql-buddy/`  
**Tech Stack:** Python · Flask · SQLite/DB connectors

An intelligent SQL assistant tool that helps write, debug, and optimize SQL queries.

**Features:**
- 🤖 AI-assisted SQL query generation
- 🌐 Web-based UI via Flask (`run_server.py`)
- 📦 Simple setup with `requirements.txt`

**Quick Start:**
```bash
cd dk-sql-buddy
pip install -r requirements.txt
python run_server.py
```

---

## 🌐 11. Portfolio Website

**Folder:** `portfolio-website/`  
**Tech Stack:** HTML · CSS · JavaScript

Personal portfolio website showcasing skills, projects, and experience.

**Features:**
- ⚡ Single-page application with smooth animations
- 🎨 Modern dark-mode UI
- 📱 Fully responsive design
- 🔗 Direct links to projects and contact

---

## 🛠️ Tech Stack Summary

| Domain | Technologies |
|---|---|
| **ML / AI** | Python, TensorFlow, Keras, scikit-learn, OpenCV, MediaPipe, NLTK |
| **Backend** | Flask, PHP, ASP.NET Core |
| **Frontend** | HTML, CSS, JavaScript, Flutter/Dart |
| **Mobile** | Android (Java/Kotlin), Flutter |
| **Database** | MySQL, Firebase Realtime DB, SQLite |
| **DevOps** | Docker, Firebase Cloud Functions, Netlify |
| **Languages** | Python, Dart, C#, Java, PHP, JavaScript |

---

## 👤 Author

**Dhruvkumar Mashru**

- 💼 [LinkedIn](https://linkedin.com/in/dhruvkumar-mashru)

---

> *Each project folder contains its own source code. Refer to individual project `README.md` files (where available) for detailed setup instructions.*
