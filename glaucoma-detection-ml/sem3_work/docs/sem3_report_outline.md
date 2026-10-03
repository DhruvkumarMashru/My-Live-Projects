# Thesis Report Outline (Semester 3 - Phase I)
## Retinal OCT-Based Early Glaucoma Detection System

This document outlines the four core chapters required for the **Semester 3 Phase I Project Report** submission.

---

## 📄 Chapter 1: Introduction
### 1.1 Clinical Background
*   Overview of glaucoma as a global leading cause of irreversible blindness.
*   Pathology of Optic Nerve Head (ONH) damage and Retinal Nerve Fiber Layer (RNFL) thinning.
*   The clinical role of Optical Coherence Tomography (OCT) in retinal diagnostics.
### 1.2 Motivation
*   Challenges of manual diagnostic screening (expert shortage, subjective readings, high healthcare costs).
*   Need for automated computer-aided diagnosis (CAD) systems.
### 1.3 Project Scope
*   Defining Phase I: Development of data pipelines, preprocessing workflows, and baseline deep learning models (Custom CNN, VGG16).
### 1.4 Objectives of Phase I
*   Dataset selection and partitioning.
*   Contrast enhancement and denoising pipeline implementation.
*   Training a custom residual CNN from scratch.
*   Training a VGG16 network via transfer learning.

---

## 📑 Chapter 2: Literature Survey
### 2.1 Traditional Glaucoma Detection Methods
*   Manual clinical diagnostic modalities (Perimetry, Fundus photography, intraocular pressure measurement).
*   Rule-based image processing algorithms (edge detection, thresholding of cup-to-disc ratios).
### 2.2 Machine Learning in Ophthalmic Imaging
*   Support Vector Machines (SVM), Random Forests, and k-NN applications on fundus scans.
*   Limitations of handcrafted feature engineering.
### 2.3 Deep Learning & Convolutional Neural Networks (CNNs)
*   State-of-the-art CNNs in medical imaging tasks.
*   Review of transfer learning versus training from scratch on clinical datasets.
*   Critical summary and identified research gaps.

---

## 🛠️ Chapter 3: Research Methodology & System Design
### 3.1 Dataset Overview
*   Kaggle Retinal OCT Dataset details (ACRIMA, ORIGA, Fundus cohorts).
*   Data distributions: Normal vs. Glaucomatous scans.
*   Train, Validation, and Test partitioning strategies (70/15/15 stratified splits).
### 3.2 Preprocessing Workflows
*   Image normalization using ImageNet statistics.
*   Image contrast enhancement via Contrast Limited Adaptive Histogram Equalization (CLAHE).
*   Denoising using Gaussian filters.
*   Augmentations (Rotation, Horizontal Flipping, Zooming) to prevent training overfitting.
### 3.3 Network Architectures
*   **Custom CNN**: Detail blocks (Convolution, BatchNorm, ReLU, MaxPool, Residual connection) and classification heads.
*   **VGG16 Model**: Transfer learning architecture, frozen feature extraction base, customized binary classification head.
### 3.4 Training Setup
*   Loss functions (Cross-Entropy with class balancing weights).
*   Optimization parameters (AdamW, initial learning rate of 1e-4, weight decay).
*   Gradient accumulation and FP16 mixed precision setups for low-VRAM memory optimizations.

---

## 📊 Chapter 4: Baseline Results, Discussion & Phase I Conclusion
### 4.1 Quantitative Performance
*   Accuracy, Loss curves, and evaluation metrics for the Custom CNN model.
*   Accuracy, Loss curves, and evaluation metrics for the VGG16 baseline model.
*   Comparative tabular results (Custom CNN vs VGG16).
### 4.2 Diagnostic Insights
*   Impact of CLAHE preprocessing on training speed and classification accuracy.
*   Performance under low GPU constraints (2GB VRAM resource limitations).
### 4.3 Summary of Phase I Deliverables
*   Status of objectives completed in Semester 3.
### 4.4 Roadmap for Semester 4 (Phase II)
*   Introduction to advanced CNN architectures (ResNet50, EfficientNetB0).
*   Ensemble learning integration.
*   Explainability mapping (Grad-CAM visualization).
*   Clinical full-stack application (Flask, SQLite dashboard).
