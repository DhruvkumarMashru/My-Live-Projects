# GlaucoScan AI — Step-by-Step System Deployment & User Guide
## Retinal OCT-Based Early Glaucoma Detection System

---

## 🔬 Clinical Research Overview
The **GlaucoScan AI** platform is a clinical decision support workspace designed to automate and explain early-stage glaucoma detection from Optical Coherence Tomography (OCT) retinal images. The system compares 5 convolutional architectures (Custom CNN, VGG16, ResNet50, EfficientNetB0, and a Weighted Ensemble) trained on local hardware (optimized for a 2GB VRAM GPU) and incorporates explainability via Gradient-Weighted Class Activation Mapping (Grad-CAM).

---

## 📁 System Requirements & Stack
*   **Operating System**: Windows 10/11 (with PowerShell/CMD support)
*   **Language**: Python 3.9+ (64-bit version required)
*   **Deep Learning Framework**: PyTorch 2.3+ (CUDA enabled for GPU acceleration)
*   **Web Framework**: Flask 3.0+ with SQLite (SQLAlchemy ORM)
*   **Hardware Baseline**: 8GB System RAM, NVIDIA GPU (2GB VRAM minimum, e.g., GeForce MX250) or CPU execution fallback.

---

## 🚀 Stepwise System Operations

### 📦 Step 1: Environment Installation
The system comes with an automated launcher (`setup_env.bat`) which configures virtual environments and registers all required dependencies.

1. Open a PowerShell or Command Prompt terminal in the project directory:
   ```powershell
   cd e:\PROJECT\glaucoma_detection_phd
   ```
2. Double-click or execute the launcher file:
   ```powershell
   .\setup_env.bat
   ```
3. Select **Option [1]** to install required Python packages. This script will upgrade `pip` and install all required frameworks (PyTorch, Torchvision, Flask, FPDF2, OpenCV, and analytics libraries).
4. Select **Option [2]** to initialize the project directory structure. This runs `config.py` to create the required data, models, reports, and upload folders.

---

### 📥 Step 2: Dataset Acquisition & Partitioning
The training pipeline requires the Kaggle Glaucoma Detection dataset (~400MB, containing ACRIMA, Fundus, and ORIGA scans).

1. **Setup Kaggle API credentials**:
   * Go to [Kaggle settings](https://www.kaggle.com/settings) and click **Create New Token** under the API section.
   * Save the downloaded `kaggle.json` file to your user profile directory:
     `C:\Users\<YourUsername>\.kaggle\kaggle.json`
2. **Download & Split Data**:
   * Launch `setup_env.bat` and select **Option [4]** (or run `python src/data/dataset_loader.py` directly).
   * This script downloads the raw dataset, extracts it, parses folder mappings, and divides the 2,005 retinal scans into a stratified distribution:
     *   **Train Set (70%)**: 1,403 images (normal: 825, glaucoma: 578)
     *   **Validation Set (15%)**: 299 images (normal: 177, glaucoma: 122)
     *   **Test Set (15%)**: 303 images (normal: 179, glaucoma: 124)

---

### 🤖 Step 3: Deep Learning Model Training
Training is heavily optimized to run on standard CUDA GPUs with only 2GB of VRAM (e.g. GeForce MX250) without memory overflow (OOM):
*   **Mixed Precision (AMP)**: Calculations are executed in float16 to reduce memory usage.
*   **Gradient Accumulation**: Accumulates gradients over 4 steps, matching a batch size of 32 while holding only 8 images in VRAM at a time.

1. Launch `setup_env.bat` and select **Option [5]** (or run the CLI command below).
2. Train individual architectures or trigger all 4 models:
   ```powershell
   # Train all models sequentially (takes ~2-4 hours on MX250 GPU)
   python src/training/train.py --model all
   
   # Or train specific models individually:
   python src/training/train.py --model efficientnet
   python src/training/train.py --model resnet50
   python src/training/train.py --model vgg16
   python src/training/train.py --model cnn
   ```
3. Training check-pointing saves the best weight files (`.pth` format) dynamically in the `models/` directory.

---

### 📊 Step 4: Quantitative Evaluation
Once training is complete, the test cohort is evaluated to compile comparative performance charts.

1. Trigger the evaluation script:
   ```powershell
   python src/evaluation/run_evaluation.py
   ```
2. The script processes the 303 unseen test scans across all models, generating:
   *   `reports/all_models_metrics.json` — Evaluated metrics database.
   *   `reports/roc_curves_all_models.png` — Comparative ROC Curve plot.
   *   `reports/sensitivity_specificity.png` — Sensitivity vs Specificity bar chart.
   *   `reports/confusion_matrix_<model>.png` — Confusion matrices for each classifier.

---

### 🌐 Step 5: Launching the Web Workspace
The Flask web interface serves as the primary clinician-facing app.

1. Launch `setup_env.bat` and select **Option [3]** (or run the entrypoint script directly):
   ```powershell
   python run.py
   ```
2. Open your web browser and navigate to: **`http://localhost:5000`**
3. *Fallback Sandbox Note*: If model weights are not trained yet, the application automatically boots into a **Demo Sandbox Mode**, using pre-seeded patients and simulated Grad-CAM heatmap overlays so the system can be reviewed immediately.

---

## 🖥️ Clinician App Walkthrough

### 1. File Upload & GPU Inference
1. Navigate to the **Scan Analysis** workspace.
2. Drag and drop a retinal OCT scan (`.jpg` or `.png`) into the upload zone.
3. Select an AI model from the dropdown menu (the **Weighted Ensemble** is recommended for the highest specificity).
4. Click **Analyze Scan**. The backend will perform real-time GPU inference, display prediction probabilities (Normal vs Glaucoma), and overlay a **Grad-CAM attention heatmap** highlighting the key anatomical diagnostic boundaries (such as the optic cup/disc borders).

### 2. Interactive Analytics Dashboard
1. Select **Dashboard** from the navigation bar.
2. Review clinical analytics showing patient distribution, historical classification counts, and real-time prediction stats.
3. Filter patient logs using the index search bar or trigger new diagnosis inputs.
4. Toggle between the **Clinical Slate Light theme** (for bright offices) and the **Glowing Navy Dark theme** (for dimmed screening rooms) using the theme switcher switch on the navbar.

### 3. Model Benchmark Comparisons
1. Click **Compare Models** in the navbar.
2. Compare the metrics of the five models side-by-side using interactive, high-contrast bar charts.
3. Review the comparative ROC curves to see the mathematical classification thresholds.

---

## 🛠️ Diagnostics & Troubleshooting

*   **CUDA Out of Memory (OOM) Errors**:
    If training fails due to VRAM limitations, reduce the training batch size in `config.py`:
    ```python
    TRAIN = {
        "batch_size": 4,  # Decrease from 8 to 4
        "gradient_accumulation_steps": 4,  # Double accumulation to maintain batch size
    }
    ```
*   **Missing Kaggle API Credentials**:
    If download fails, place the manual dataset zip at `data/raw/glaucoma-detection.zip` and select Option [4] in the batch launcher to extract it.
*   **Database Reset**:
    To purge database logs and restart seeding, delete `webapp/glaucoma.db`. The Flask backend will re-initialize and seed it automatically on the next launch.

---
*Developed by Lead AI Researcher under the guidance of Clinical Research Advisor, Institute of Advanced Medical Sciences & Engineering (June 2026).*
