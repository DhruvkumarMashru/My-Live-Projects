"""
======================================================================
  Fake News Detection System — System Configuration
======================================================================
  M.Tech Academic Project
  Year: 2026
======================================================================
"""

import os
import sys
from pathlib import Path

# Reconfigure stdout/stderr to UTF-8 to handle emojis on Windows
if sys.platform.startswith('win'):
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8')

# ── Project Root ────────────────────────────────────────────────────
ROOT_DIR = Path(__file__).parent.resolve()

# ── Paths ────────────────────────────────────────────────────────────
PATHS = {
    "models_dir":    ROOT_DIR / "models",
    "reports_dir":   ROOT_DIR / "reports",
    "docs_dir":      ROOT_DIR / "docs",
    "db_path":       ROOT_DIR / "webapp" / "fake_news.db",
    "nltk_data_dir": ROOT_DIR / "nltk_data",
    "dataset_dir":   ROOT_DIR / "data" / "raw",
}

# ── Dataset Configuration ────────────────────────────────────────────
DATASET = {
    "raw_dir":   PATHS["dataset_dir"],
    "file_path": PATHS["dataset_dir"] / "news_dataset.csv",
    "classes":   ["real", "fake"],
}

# ── Register NLTK Data Path ──────────────────────────────────────────
import nltk
PATHS["nltk_data_dir"].mkdir(exist_ok=True)
nltk.data.path.insert(0, str(PATHS["nltk_data_dir"]))

# ── Model Configuration ──────────────────────────────────────────────
MODELS = {
    "pac": {
        "name": "Passive Aggressive Classifier",
        "description": "Optimized for online textual data streams. Utilizes passive steps for correct classifications and aggressive updates on errors.",
        "file": "model_pac.pkl",
    },
    "nb": {
        "name": "Multinomial Naive Bayes",
        "description": "Classic probabilistic text classifier based on Bayes' Theorem, calculating conditional probability of word bags.",
        "file": "model_nb.pkl",
    },
    "lr": {
        "name": "Logistic Regression",
        "description": "Standard linear classification model with l2 regularization, providing probability estimates using the sigmoid function.",
        "file": "model_lr.pkl",
    },
    "ensemble": {
        "name": "Weighted Voting Ensemble",
        "description": "Combines predictions from Passive Aggressive, Naive Bayes, and Logistic Regression with optimal classification weights.",
        "file": "model_ensemble.pkl",
        "weights": [0.45, 0.25, 0.30], # PAC, Naive Bayes, Logistic Regression
    }
}

# ── Vectorizer Hyperparameters ───────────────────────────────────────
VECTORIZER = {
    "max_features": 5000,
    "ngram_range":  (1, 2),  # unigrams and bigrams
    "file":         "tfidf_vectorizer.pkl",
}

# ── Flask Configuration ──────────────────────────────────────────────
FLASK = {
    "debug":       False,
    "port":        5000,
    "host":        "127.0.0.1",
    "secret_key":  "fake_news_nlp_mtech_project_secret_key_2026",
}

# ── Create Required Directories ───────────────────────────────────────
def create_directories():
    dirs = [
        PATHS["models_dir"],
        PATHS["reports_dir"],
        PATHS["docs_dir"],
        PATHS["nltk_data_dir"],
        PATHS["db_path"].parent,
        PATHS["dataset_dir"]
    ]
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)
    print("✅ System directories initialized successfully.")

if __name__ == "__main__":
    create_directories()
    print(f"Project root: {ROOT_DIR}")
