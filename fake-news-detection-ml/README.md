# VeriTrack AI — Fake News Detection System
## Explainable NLP & Machine Learning Classification Workspace

VeriTrack AI is an M.Tech-level automated verification portal designed to classify news articles as genuine or fake. The system utilizes advanced Natural Language Processing (NLP) token cleaning and benchmarks multiple machine learning models (Passive Aggressive, Naive Bayes, Logistic Regression, and a Soft-Voting Ensemble). 

To ensure clinical-grade trust, it integrates **Explainable AI (XAI)** principles, generating word-attribution maps that highlight fake indicators (in Red) and factual indicators (in Green) in real-time.

---

## 📁 System Directory Structure
```
fake_news_detection/
├── config.py              # Central project configuration and directories initializer
├── requirements.txt       # Dependencies manifest (Flask, scikit-learn, NLTK)
├── run.py                 # Quickstart web application server launcher
├── setup_env.bat          # Automated environment installer and utility script
│
├── data/                  # Structured news dataset folder
│   ├── raw/
│   │   └── news_dataset.csv # Raw news headline and body text records
│   └── processed/
│       └── cleaned_news_dataset.csv # Processed cleaned text dataset
│
├── src/
│   ├── data/
│   │   └── data_preprocessing.py # Preprocessing & token clean modules
│   ├── training/
│   │   └── train_models.py       # ML models training & evaluation curves pipeline
│   └── evaluation/
│       ├── explainer.py          # Word attributions explainability highlighter
│       └── metrics.py            # Comparative confusion matrices exporter
│
├── webapp/                # Web Dashboard Application
│   ├── app.py             # Flask Web Server
│   ├── templates/         # UI HTML pages (index, dashboard, compare)
│   ├── static/
│   │   ├── css/style.css  # Dark glassmorphism stylesheet
│   │   └── js/main.js     # AJAX controllers and front-end interactions
│   └── fake_news.db       # Persistent SQLite prediction database
│
├── models/                # Serialized vectorizers & model check-points (.pkl)
├── reports/               # Performance comparisons & evaluation charts
└── docs/                  # Academic portfolio deliverables
    ├── synopsis.md              # Project Synopsis
    ├── report_outline.md        # 7-Chapter thesis document outline
    ├── user_guide.md            # App deployment and user guide
    └── presentation_guide.md    # 15-slide viva slide pack guides
```

---

## 🚀 Quick Start Guide

### Step 1: Environment Setup
Open a terminal in the project directory and run the launcher script:
```powershell
.\setup_env.bat
```
1. Select **Option [1]** to install all required libraries.
2. Select **Option [2]** to download NLTK datasets. This will automatically download and set up NLTK stopwords and WordNet datasets into the local `nltk_data/` directory.

### Step 2: Model Training & Reports Compilation
Select **Option [3]** in `setup_env.bat` (or run `python src/training/train_models.py` directly).
This script:
*   Generates a synthetic news corpus.
*   Trains all models.
*   Generates comparative charts and confusion matrices in the `reports/` folder.
*   Saves the serialized weights in the `models/` folder.

### Step 3: Start Web Server Workspace
Select **Option [4]** in `setup_env.bat` (or run `python run.py`).
Once running, open your web browser and navigate to: **`http://127.0.0.1:5000`**

---

## 📄 Academic Portfolios
All documents needed for project review submissions are placed in `docs/`:
1. **Project Synopsis** (`docs/synopsis.md`): Structured abstract, objectives, and methodologies.
2. **Thesis Outline** (`docs/report_outline.md`): Full 7-chapter draft outline.
3. **User Manual** (`docs/user_guide.md`): Deployment guide.
4. **Slide Outline** (`docs/presentation_guide.md`): 15-slide viva defense review structures.
