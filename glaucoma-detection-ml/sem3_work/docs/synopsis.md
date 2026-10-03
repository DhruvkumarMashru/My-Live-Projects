# Project Synopsis (Semester 3 - Phase I)
## Advanced Retinal OCT-Based Early Glaucoma Detection System
### Baseline Deep Learning Classification Pipeline

---

**Investigator   :** Master's Student AI Project Candidate  
**Course & Sem   :** Master of Technology (M.Tech), Semester 3  
**Department      :** Department of Computer Science & Engineering / AI & Data Science  
**Supervisor      :** Clinical & Engineering Project Advisor  

---

## 1. Introduction
Glaucoma is a chronic, progressive optic neuropathy characterized by irreversible damage to retinal ganglion cells and their axons, leading to permanent vision loss if undetected. Since early-stage glaucoma is largely asymptomatic, screening retinal scans is crucial. Optical Coherence Tomography (OCT) provides high-resolution retinal nerve fiber layer (RNFL) cross-sections, but manual analysis is expert-dependent, costly, and subjective. 

In Phase I (Semester 3), we implement a **deep learning-based automated screening baseline** using a stratified training pipeline on retinal OCT scans, benchmarking a custom deep neural network against a traditional transfer learning base (VGG16) to establish a baseline classification standard.

---

## 2. Problem Statement
Automated glaucoma screening requires high sensitivity to minimize false negatives. The current challenges include:
- Accessibility of expert ophthalmological reviews in remote areas.
- High subjectivity of clinical features (optic cup/disc ratio assessment).
- High computational requirements for standard AI pipelines.
This project establishes a memory-efficient baseline framework utilizing consumer-grade GPU architectures.

---

## 3. Phase I (Semester 3) Objectives
1. **Pipeline Implementation**: Establish a robust PyTorch data ingestion pipeline for raw OCT images (Normal vs. Glaucoma classes).
2. **Preprocessing System**: Integrate Contrast Limited Adaptive Histogram Equalization (CLAHE) to enhance contrast of optic discs and denoise images.
3. **Model Development**: Build and train a **Custom Residual-style CNN** from scratch.
4. **Transfer Learning Baseline**: Adapt and fine-tune a pre-trained **VGG16 Network** as a comparative standard.
5. **Evaluation**: Benchmark accuracy, sensitivity, and loss curves on a dedicated test cohort.
6. **Academic Documentation**: Compile the Phase I literature survey, methodology design, and intermediate results.

---

## 4. Methodology & Baseline Models

### 4.1 Dataset & Splits
Utilizes the Kaggle Retinal OCT dataset for Glaucoma Detection, partitioned into:
- **Training Set (70%)** for gradient optimization.
- **Validation Set (15%)** for hyperparameter tuning.
- **Test Set (15%)** for unbiased evaluation.

### 4.2 Pipeline Enhancements
- Contrast Enhancement: CLAHE to highlight RNFL thinnings.
- Data Augmentation: Random rotations, horizontal flips, and color jitter to prevent overfitting on smaller cohorts.

### 4.3 Implemented Networks
1. **Custom CNN**: A residual-style network containing conv-blocks, batch normalization, max-pooling, and a dropout classifier head (~4.2M parameters).
2. **VGG16 Transfer Learning**: A classic deep network initialized with ImageNet pre-trained weights, with the bottom convolutional blocks frozen to act as a robust feature extractor (~138M parameters).

---

## 5. Intermediate System Architecture
```
[Raw Retinal OCT Scan]
          ↓
[Denoising & CLAHE Preprocessing]
          ↓
[Custom CNN Classifier]  OR  [VGG16 Baseline Network]
          ↓
[Sigmoid/Softmax Classification Head]
          ↓
[Prediction Result: Normal / Glaucoma]
```

---

## 6. Expected Phase I Outcomes
- Successful pipeline construction and dataset ingestion.
- Denoising and contrast improvement verified via image overlays.
- Custom CNN achieving **≥88%** binary classification accuracy.
- VGG16 Transfer Learning achieving **≥91%** binary classification accuracy.
- Completion of Chapter 1-4 thesis draft (Introduction, Literature Survey, Methodology, Intermediate Results).

---

## 7. Phase I Tools & Libraries
- **Programming**: Python 3.9+
- **Deep Learning**: PyTorch, Torchvision
- **Computer Vision**: OpenCV, PIL, Albumentations
- **Data Visualisation**: Matplotlib, Seaborn
- **Development Environment**: VS Code / PyCharm / Jupyter Notebooks
