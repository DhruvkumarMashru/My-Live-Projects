# GlaucoScan AI — Semester 3 (Phase I Portfolio)
## Retinal OCT-Based Early Glaucoma Detection System

This workspace contains the **Phase I (Semester 3)** deliverables for the automated glaucoma detection project. The scope is limited to data preprocessing, baseline model engineering, and initial performance evaluation.

---

## 📁 Semester 3 Project Structure
```
sem3_work/
├── config.py              # ← Central configuration (VGG16 & CNN only)
├── requirements.txt       # ← All required libraries
├── setup_env.bat          # ← Semester 3 launcher (web app disabled)
│
├── src/
│   ├── data/
│   │   └── dataset_loader.py    # ← Preprocessing & DataLoaders
│   ├── training/
│   │   ├── model_cnn.py         # ← Custom CNN definition
│   │   ├── model_transfer.py    # ← VGG16 Transfer Learning baseline
│   │   └── train.py             # ← Training script (CNN & VGG16 only)
│   └── evaluation/
│       ├── metrics.py           # ← Plotting curves & metrics
│       └── run_evaluation.py    # ← Evaluates baseline models
│
├── docs/
│   ├── synopsis.md              # ← Semester 3 Synopsis
│   ├── sem3_report_outline.md   # ← Thesis Chapters 1-4 Outline
│   └── sem3_presentation_guide.md # ← Slide guidelines for Sem 3 review
│
├── models/                # ← Directory for saving checkpoints (.pth)
└── reports/               # ← Directory for generated evaluation plots
```

---

## 🚀 Getting Started & Operations

### Step 1: Environment Setup
Open a terminal in this directory and execute the environment launcher:
```powershell
.\setup_env.bat
```
- Select **Option [1]** to install required libraries.
- Select **Option [2]** to initialize runtime directory paths.

### Step 2: Download Dataset
- Set up Kaggle credentials (`kaggle.json`) or place the dataset zip at `data/raw/glaucoma-detection.zip`.
- Run the setup utility launcher and select **Option [4]** to split raw OCT scans.

### Step 3: Train Baseline Models
- Select **Option [5]** to train:
  - **Custom CNN** (from scratch)
  - **VGG16** (transfer learning baseline)
- Run-time metrics will save under `reports/` and checkpoint weights under `models/`.

### Step 4: Run Evaluation
To compare performance between your custom CNN and VGG16, execute:
```powershell
python src/evaluation/run_evaluation.py
```
This generates comparative ROC curves, confusion matrices, and metrics JSON under `reports/`.

---

## 📄 Academic Portfolio
All documentation required for Semester 3 submission is located in the `docs/` directory:
1. **Synopsis** (`docs/synopsis.md`): Baseline project summary.
2. **Report Chapters 1-4** (`docs/sem3_report_outline.md`): Structured draft chapters.
3. **Presentation Guide** (`docs/sem3_presentation_guide.md`): Slide outline for viva committee.
