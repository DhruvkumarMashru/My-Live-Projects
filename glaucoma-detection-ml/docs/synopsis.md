# Project Synopsis
## Advanced Retinal OCT-Based Early Glaucoma Detection System
### A Deep Learning Approach Using Multiple CNN Architectures

---

**Investigator   :** Lead AI Research Investigator  
**Department      :** Department of Ophthalmic Imaging & AI Diagnostics  
**Institution     :** Institute of Advanced Medical Sciences & Engineering  
**Supervisor      :** Clinical Research Supervisor  
**Submission Date :** June 2026  

---

## 1. Introduction

Glaucoma is a chronic, progressive optic neuropathy characterised by irreversible damage to retinal ganglion cells and their axons, ultimately leading to permanent vision loss. It is the second leading cause of blindness worldwide, affecting over **80 million people globally** as of 2023. The insidious nature of glaucoma — where significant vision loss occurs before any subjective symptoms are noticed — makes early detection critical.

Optical Coherence Tomography (OCT) has emerged as a gold-standard imaging modality for glaucoma screening, providing high-resolution cross-sectional images of the retinal nerve fibre layer (RNFL) and optic disc. However, manual interpretation of OCT scans requires highly trained ophthalmologists and is time-consuming, expensive, and subjective.

This project proposes an **Advanced Retinal OCT-Based Early Glaucoma Detection System** using state-of-the-art deep learning techniques to automate and enhance the accuracy of glaucoma diagnosis from OCT retinal images.

---

## 2. Problem Statement

Despite advances in ophthalmic imaging, glaucoma screening remains challenged by:
- **Shortage of trained ophthalmologists** in developing regions
- **High cost** of specialised diagnostic equipment and expertise
- **Subjectivity** in manual image interpretation
- **Delayed diagnosis** due to asymptomatic early stages

There is a critical need for an automated, accurate, and explainable AI system capable of detecting glaucoma from retinal OCT images at scale.

---

## 3. Objectives

1. To develop a robust deep learning pipeline for binary classification (Normal/Glaucoma) of retinal OCT images
2. To implement and compare five state-of-the-art CNN architectures: Custom CNN, VGG16, ResNet50, EfficientNetB0, and an Ensemble model
3. To achieve ≥95% classification accuracy on the held-out test set
4. To implement Gradient-weighted Class Activation Mapping (Grad-CAM) for model explainability
5. To develop a full-stack web application for clinical deployment with patient record management
6. To evaluate models using clinically relevant metrics: sensitivity, specificity, AUC-ROC, F1-score

---

## 4. Methodology

### 4.1 Dataset
The **Kaggle Glaucoma Detection Dataset** (sshikamaru/glaucoma-detection) comprising retinal OCT scans with binary labels (Normal/Glaucoma) is utilised. The dataset contains approximately 1,200+ images across two classes, split into 70% training, 15% validation, and 15% testing sets using stratified sampling.

### 4.2 Preprocessing Pipeline
- **CLAHE** (Contrast Limited Adaptive Histogram Equalization) for enhanced optic disc contrast
- **Gaussian denoising** for noise reduction
- **Normalisation** using ImageNet channel statistics
- **Data augmentation**: random cropping, horizontal/vertical flips, rotation (±15°), colour jittering

### 4.3 Deep Learning Models

| Model | Architecture | Parameters | Approach |
|-------|-------------|-----------|---------|
| Custom CNN | Residual-style CNN | ~4.2M | Trained from scratch |
| VGG16 | Very Deep CNN | ~138M | Transfer Learning (frozen layers 1-10) |
| ResNet50 | Residual Network | ~25M | Transfer Learning (frozen layers 1-6) |
| EfficientNetB0 | Compound Scaled | ~5.3M | Transfer Learning (frozen layers 1-5) |
| Ensemble | Combined | N/A | Weighted soft-probability averaging |

### 4.4 Training Strategy
- **Optimiser**: AdamW with weight decay 1e-4
- **Learning Rate**: 1e-4 with ReduceLROnPlateau scheduler
- **Loss Function**: Cross-Entropy with class-balanced weights
- **Mixed Precision Training** (FP16) for memory efficiency
- **Gradient Accumulation** (4 steps, effective batch=32)
- **Early Stopping** (patience=10 epochs)
- **Epochs**: Up to 50 per model

### 4.5 Explainability
Grad-CAM (Gradient-weighted Class Activation Mapping) is implemented to visualise which retinal regions (particularly the optic disc and cup) most influence the model's classification decisions, enhancing clinical interpretability.

---

## 5. System Architecture

```
OCT Image Input
    ↓
CLAHE Preprocessing + Augmentation
    ↓
Feature Extraction (5 CNN Models)
    ↓
Classification Head (Fully Connected Layers)
    ↓
Soft-max Probability Output
    ↓
Ensemble Aggregation (Weighted Average)
    ↓
Binary Decision: Normal / Glaucoma
    +
Grad-CAM Heatmap (Explainability)
```

---

## 6. Web Application

A full-stack web application is developed using:
- **Backend**: Flask (Python) with SQLite database
- **Frontend**: Premium dark glassmorphism UI with real-time prediction
- **Features**: Drag-and-drop upload, model selection, Grad-CAM visualisation, patient history dashboard, performance comparison charts

---

## 7. Expected Outcomes

| Metric | Target |
|--------|--------|
| Custom CNN Accuracy | ≥88% |
| VGG16 Accuracy | ≥91% |
| ResNet50 Accuracy | ≥93% |
| EfficientNetB0 Accuracy | ≥95% |
| Ensemble Accuracy | ≥96% |
| AUC-ROC (Ensemble) | ≥0.97 |
| Sensitivity | ≥94% |
| Specificity | ≥93% |

---

## 8. Significance

This system contributes to:
1. **Healthcare accessibility**: Automated screening in resource-limited settings
2. **Clinical decision support**: Explainable AI for ophthalmologists
3. **Research**: Benchmarking multiple state-of-the-art architectures on OCT data
4. **Education**: Demonstrating transfer learning application in medical imaging

---

## 9. Tools & Technologies

| Category | Tools |
|----------|-------|
| Programming | Python 3.9+ |
| Deep Learning | PyTorch 2.0, torchvision |
| Computer Vision | OpenCV, PIL, albumentations |
| Web Framework | Flask 3.x |
| Database | SQLite (Flask-SQLAlchemy) |
| Visualisation | Matplotlib, Seaborn, Plotly |
| Explainability | Grad-CAM |
| Notebooks | Jupyter |

---

## 10. References

1. Selvaraju, R.R., et al. "Grad-cam: Visual explanations from deep networks via gradient-based localization." ICCV 2017.
2. He, K., et al. "Deep residual learning for image recognition." CVPR 2016.
3. Tan, M., & Le, Q. "Efficientnet: Rethinking model scaling for convolutional neural networks." ICML 2019.
4. Simonyan, K., & Zisserman, A. "Very deep convolutional networks for large-scale image recognition." ICLR 2015.
5. Ting, D.S.W., et al. "Development and validation of a deep learning system for diabetic retinopathy and related eye diseases." JAMA 2017.
6. Diaz-Pinto, A., et al. "CNNs for automatic glaucoma assessment using fundus images." BioMedical Engineering OnLine 2019.

---

*This document serves as the official project synopsis for the research and implementation project submission.*
