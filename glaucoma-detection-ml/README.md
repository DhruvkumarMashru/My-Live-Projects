# Advanced Retinal OCT-Based Early Glaucoma Detection System
## Complete System Guide

[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://python.org)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.0+-orange.svg)](https://pytorch.org)
[![Flask](https://img.shields.io/badge/Flask-3.0+-green.svg)](https://flask.palletsprojects.com)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

---

## 🔬 Project Overview

This is an **advanced, full-stack deep learning system** for early glaucoma detection from Retinal OCT images. The system implements and compares **5 state-of-the-art deep learning models** with a premium web application, database integration, and Grad-CAM explainability.

### ✅ All Deliverables Included
- 📄 Project Synopsis (`docs/synopsis.md`)
- 📑 Report Outline (`docs/report_outline.md`)
- 💻 Complete Source Code (this repository)
- 📊 Dataset Integration (Kaggle OCT dataset)
- 🤖 5 Model Training & Testing scripts
- 📈 Accuracy & Performance Evaluation (with charts)
- 🌐 Advanced Web Application (Flask)
- 🗄️ Database Integration (SQLite)
- 🔥 Grad-CAM Explainability

---

## 🧠 Models Implemented

| # | Model | Architecture | Expected Accuracy |
|---|-------|-------------|------------------|
| 1 | Custom CNN | Purpose-built with residual blocks | ~88% |
| 2 | VGG16 | Transfer Learning (ImageNet) | ~91% |
| 3 | ResNet50 | Transfer Learning (ImageNet V2) | ~93% |
| 4 | EfficientNetB0 | Transfer Learning (ImageNet) | ~95% |
| 5 | Ensemble | Weighted combination (ResNet+EfficientNet+VGG) | ~96%+ |

---

## 📁 Project Structure

```
glaucoma_detection_phd/
├── config.py                    # ← Central configuration (edit paths here)
├── requirements.txt             # ← All dependencies
├── README.md                    # ← This file
│
├── src/
│   ├── data/
│   │   └── dataset_loader.py    # ← Kaggle download + DataLoaders
│   ├── training/
│   │   ├── model_cnn.py         # ← Custom CNN model
│   │   ├── model_transfer.py    # ← VGG16, ResNet50, EfficientNetB0
│   │   ├── model_ensemble.py    # ← Ensemble model
│   │   └── train.py             # ← Main training script
│   └── evaluation/
│       ├── metrics.py           # ← All performance metrics + plots
│       └── gradcam.py           # ← Grad-CAM explainability
│
├── webapp/
│   ├── app.py                   # ← Flask web server
│   ├── templates/
│   │   ├── index.html           # ← Main upload page
│   │   ├── dashboard.html       # ← Analytics dashboard
│   │   └── compare.html         # ← Model comparison page
│   └── static/
│       ├── css/style.css        # ← Premium dark UI
│       └── js/main.js           # ← Frontend interactions
│
├── models/                      # ← Saved model checkpoints (.pth)
├── reports/                     # ← Generated charts, metrics JSON
├── data/
│   ├── raw/                     # ← Downloaded dataset
│   └── processed/               # ← train/val/test splits
│       ├── train/normal/
│       ├── train/glaucoma/
│       ├── val/normal/
│       ├── val/glaucoma/
│       ├── test/normal/
│       └── test/glaucoma/
└── docs/
    ├── synopsis.md              # ← Project synopsis
    └── report_outline.md        # ← System report outline
```

---

## ⚡ Quick Start

### Step 1: Install Dependencies
```powershell
cd e:\PROJECT\glaucoma_detection_phd
pip install -r requirements.txt
```

### Step 2: Setup Kaggle API
1. Go to [https://www.kaggle.com/settings](https://www.kaggle.com/settings) → **API** → **Create New Token**
2. Download `kaggle.json`
3. Place at: `C:\Users\<YourName>\.kaggle\kaggle.json`

### Step 3: Create Directories & Download Dataset
```powershell
python config.py
python src/data/dataset_loader.py
```

### Step 4: Train Models (GPU recommended)
```powershell
# Train all 4 models (takes ~2-4 hours on 2GB GPU)
python src/training/train.py --model all

# Or train individually (fastest first)
python src/training/train.py --model efficientnet
python src/training/train.py --model resnet50
python src/training/train.py --model vgg16
python src/training/train.py --model cnn
```

### Step 5: Run Web Application
```powershell
cd webapp
python app.py
```
Open your browser: **http://localhost:5000**

---

## 🖥️ GPU Optimizations (2GB VRAM)

This project is specifically optimised for 2GB GPU VRAM:

| Optimization | Configuration |
|---|---|
| Batch size | 8 (small) |
| Mixed Precision | AMP (FP16) enabled |
| Gradient Accumulation | 4 steps (effective batch = 32) |
| Image size | 224×224 |
| Model selection | EfficientNetB0 (not B3) |

---

## 📊 Model Performance (After Training)

After running `train.py`, all metrics will be saved to `reports/`:
- `training_curves_<model>.png` — Loss/accuracy curves per epoch
- `confusion_matrix_<model>.png` — Confusion matrix
- `roc_curves_all_models.png` — Comparative ROC curves
- `model_comparison_chart.png` — Bar chart of all metrics
- `all_models_metrics.json` — All metrics in JSON format

---

## 🌐 Web Application Features

| Feature | Description |
|---|---|
| 🖼️ Drag & Drop Upload | Upload retinal OCT images |
| 🤖 Model Selection | Choose from any of the 5 models |
| 📊 Real-time Results | Confidence bars with % probabilities |
| 🔥 Grad-CAM | Visual explanation heatmaps |
| 👥 Patient Management | Save patient records |
| 📋 Dashboard | View all prediction history |
| 📈 Model Comparison | Performance metrics comparison |
| 🗄️ SQLite Database | All data persisted locally |

---

## 📄 Academic Deliverables

| Deliverable | Location |
|---|---|
| Project Synopsis | `docs/synopsis.md` |
| Report Outline (7 Chapters) | `docs/report_outline.md` |
| Source Code | `src/` + `webapp/` |
| Training Notebooks | `notebooks/` (run after training) |
| Performance Metrics | `reports/` (generated after training) |
| Confusion Matrices | `reports/confusion_matrix_*.png` |
| ROC Curves | `reports/roc_curves_all_models.png` |

---

## ⚠️ Important Notes

- This project is for **research/educational purposes only**
- **Not a substitute** for professional medical diagnosis
- All trained models saved automatically to `models/` directory
- Web application runs locally — no internet required after setup

---

## 📬 Support

For any issues with the code, please check:
1. Python version: `python --version` (needs 3.9+)
2. CUDA available: `python -c "import torch; print(torch.cuda.is_available())"`
3. All packages installed: `pip list | grep torch`
