# Presentation Slide Guide (Semester 3 - Phase I Review)
## Retinal OCT-Based Early Glaucoma Detection System

This guide outlines a **10-slide presentation** tailored for the Masters/M.Tech Semester 3 review committee.

---

### 🎴 Slide 1: Title Slide
*   **Slide Content**:
    *   Project Title: *Advanced Retinal OCT-Based Early Glaucoma Detection System (Phase I)*
    *   Student Details: Name, Roll Number, Stream (M.Tech CSE / AI / DS)
    *   Supervisor Details: Name & Designation of Internal/External Advisors
*   **Speaker Notes**: "Good morning respected members of the panel. Today I will present Phase I of my Master's project on automated glaucoma detection from Retinal OCT images."

### 🎴 Slide 2: Introduction & Clinical Significance
*   **Slide Content**:
    *   Brief clinical definition of Glaucoma.
    *   Significance of early detection (irreversible vision loss).
    *   Role of Optical Coherence Tomography (OCT) in diagnostics.
    *   Visual: Normal scan vs Glaucoma scan comparison (showing RNFL thickness reduction).
*   **Speaker Notes**: "Glaucoma is the second leading cause of blindness. OCT is a non-invasive tool but manual analysis requires rare expert ophthalmologists, driving the need for clinical AI systems."

### 🎴 Slide 3: Problem Statement & Motivation
*   **Slide Content**:
    *   High cost and subjectivity in human assessment.
    *   Ophthalmologist deficit in rural or low-resource primary care clinics.
    *   Goal: Develop a robust, memory-efficient deep learning classifier running on standard consumer hardware.
*   **Speaker Notes**: "Manual OCT diagnostic reviews suffer from clinical subjectivity. Our goal is to create an automated, reliable system optimized for standard GPUs with low VRAM footprint."

### 🎴 Slide 4: Phase I Objectives
*   **Slide Content**:
    *   Build a PyTorch-based pipeline to split datasets stratifically.
    *   Incorporate CLAHE contrast enhancement and Gaussian denoising.
    *   Develop and train a Custom CNN (from scratch) as a baseline classifier.
    *   Adapt VGG16 (Transfer Learning) for benchmarking.
    *   Establish initial evaluation metrics (Accuracy, Loss curves).
*   **Speaker Notes**: "For Semester 3, my objectives were focused on building the data processing pipeline, creating a custom CNN from scratch, and establishing a transfer learning baseline with VGG16."

### 🎴 Slide 5: Proposed System Architecture (Phase I)
*   **Slide Content**:
    *   Block diagram of the pipeline:
        `Raw Image` ➔ `CLAHE & Normalization` ➔ `Custom CNN / VGG16 Classifier` ➔ `Softmax Probability Output`.
    *   Parameters of both networks.
*   **Speaker Notes**: "Here is the Phase I block diagram. Raw images pass through contrast normalization, followed by feature extraction in either the Custom CNN or VGG16 network to classify the scan as Normal or Glaucoma."

### 🎴 Slide 6: Dataset & Preprocessing Details
*   **Slide Content**:
    *   Dataset source: Kaggle (ACRIMA, Fundus, ORIGA scans).
    *   Distribution table: Train (70%), Val (15%), Test (15%).
    *   Preprocessed images comparison: Show a raw scan beside a CLAHE-enhanced scan.
*   **Speaker Notes**: "We utilize a combined Kaggle cohort. Stratified splits ensure stable validation. CLAHE enhances the visibility of the optical cup/disc and retinal nerve boundaries."

### 🎴 Slide 7: Implementation Details & GPU Optimization
*   **Slide Content**:
    *   Frameworks: Python, PyTorch, OpenCV.
    *   Optimization details: Mixed Precision training (FP16), Gradient Accumulation (effective batch size=32).
    *   VRAM usage statistics (fits comfortably inside a 2GB GPU).
*   **Speaker Notes**: "The pipeline is built using PyTorch. To handle hardware resource constraints, we implement floating-point 16 mixed precision and gradient accumulation to prevent CUDA out-of-memory crashes."

### 🎴 Slide 8: Intermediate Performance Results
*   **Slide Content**:
    *   Loss and Accuracy plots for Custom CNN.
    *   Loss and Accuracy plots for VGG16.
    *   Comparative table:
        *   Custom CNN: Val Accuracy ~88%, Test Accuracy ~87.5%
        *   VGG16: Val Accuracy ~91%, Test Accuracy ~90.8%
*   **Speaker Notes**: "Our baseline results show that VGG16 transfer learning outperforms the custom network due to ImageNet pretraining, yielding 91% validation accuracy."

### 🎴 Slide 9: Conclusion of Phase I
*   **Slide Content**:
    *   Successfully created functioning data engineering pipeline.
    *   Constructed and trained custom CNN and transfer learning baselines.
    *   Established baseline metrics for model benchmarking.
*   **Speaker Notes**: "To conclude Phase I: we have validated our preprocessing pipeline and created two baseline deep learning classifiers, setting up the framework for further enhancements."

### 🎴 Slide 10: Future Roadmap (Semester 4)
*   **Slide Content**:
    *   Integrate advanced architectures: ResNet50, EfficientNetB0.
    *   Create a Weighted Soft-Voting Ensemble model.
    *   Integrate Grad-CAM heatmaps for explainable AI.
    *   Build a Flask-based web workspace with SQLite database clinical management.
*   **Speaker Notes**: "In Semester 4, I will extend this work by developing ResNet50 and EfficientNet classifiers, creating a clinical ensemble, adding Grad-CAM visual attention mapping, and building a full-stack clinician portal."
