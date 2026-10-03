# Presentation Slide Guide (M.Tech Final Thesis Viva)
## Fake News Detection System Using NLP & Machine Learning

This guide outlines a **15-slide presentation** tailored for the M.Tech thesis defense/viva committee.

---

### 🎴 Slide 1: Title Slide
*   **Slide Content**:
    *   Thesis Title: *Explainable Fake News Detection System Using Natural Language Processing & Machine Learning*
    *   Candidate Details: Student Name, Roll Number, Program (M.Tech CSE / AI / DS)
    *   Research Advisor Details: Supervisor Name, Academic Rank, Department
*   **Speaker Notes**: "Respected members of the review board, today I will present my M.Tech thesis project, which focuses on developing an explainable fake news classification pipeline using NLP and Machine Learning benchmarks."

### 🎴 Slide 2: Project Overview & Scientific Challenges
*   **Slide Content**:
    *   The digital misinformation epidemic and its consequences.
    *   Challenge 1: Identifying linguistic clickbait structures.
    *   Challenge 2: The 'Black-Box' problem of traditional deep learning NLP models.
    *   Challenge 3: Resource-constrained hospital/newsroom deployment constraints.
*   **Speaker Notes**: "The unchecked speed of digital news dissemination makes manual fact-checking impossible. Our system targets semantic clickbait detection while resolving model explainability in a highly CPU-efficient framework."

### 🎴 Slide 3: Research Objectives
*   **Slide Content**:
    *   Construct an optimized NLTK-based text cleaning and lemmatization pipeline.
    *   Build a vocabulary-constrained n-gram TF-IDF vector space.
    *   Benchmark and serialize three standard ML classifiers (PAC, MNB, LR).
    *   Formulate a weighted soft-voting ensemble model.
    *   Develop a local visual explainability (XAI) token-highlighter.
    *   Deploy a Flask clinician/user workspace integrated with an SQLite database registry.
*   **Speaker Notes**: "My research goals are to build a complete diagnostic pipeline, benchmark multiple models, implement visual attribution to explain predictions, and deploy it as a functional web database dashboard."

### 🎴 Slide 4: Literature Review & Identified Gaps
*   **Slide Content**:
    *   *Rule-Based Systems*: Fail on lexical paraphrasing.
    *   *Deep Learning / LLMs*: High computation requirement, lack local user explainability.
    *   *Explainable models (LIME, SHAP)*: High computational overhead in real-time server rendering.
    *   *Research Gap*: A lightweight, local web framework that computes word-level attributions instantly using model parameters.
*   **Speaker Notes**: "While deep learning models achieve high accuracy, they are black boxes. Current explainability frameworks are computationally heavy. We address this gap by mapping model weights directly to original tokens in real-time."

### 🎴 Slide 5: System Architecture & Data Flow
*   **Slide Content**:
    *   Complete flowchart diagram:
        `Raw Text` ➔ `NLTK Pipeline` ➔ `TF-IDF Matrix` ➔ `Classifiers Pool` ➔ `Voting Ensemble` ➔ `Verdict Output` & `Grad-CAM text equivalent highlights` ➔ `SQL Database logs`.
*   **Speaker Notes**: "This flowchart demonstrates the system architecture. User text is preprocessed and vectorized using TF-IDF. The feature matrix is evaluated across three baseline models, and their soft-probability outputs are averaged in our voting ensemble."

### 🎴 Slide 6: NLTK Preprocessing Pipeline
*   **Slide Content**:
    *   Standardization: Case folding and regex punctuation filtering.
    *   Tokenization: Splitting document strings into lists of words.
    *   Stopwords Removal: Filtering structural words (English NLTK corpus).
    *   Lemmatization: Converting inflected forms to base dictionary forms (WordNet Lemmatizer).
*   **Speaker Notes**: "To ensure clean feature matrices, raw text is lowercase-folded and stripped of non-alphabetic characters. Stopwords are filtered, and words are reduced to their dictionary roots using WordNet."

### 🎴 Slide 7: Feature Engineering: N-Gram TF-IDF
*   **Slide Content**:
    *   Mathematical formulation of Term Frequency (TF) and Inverse Document Frequency (IDF).
    *   N-Gram strategy: Combining unigrams and bigrams (e.g. "secret cure" as a single feature) to preserve contextual phrases.
    *   Max features ceiling (5,000) to ensure high computational speeds.
*   **Speaker Notes**: "We extract features using TF-IDF. By combining unigrams and bigrams, we capture key phrases like 'secret society' or 'interest rate' rather than individual words, which boosts classifier sensitivity."

### 🎴 Slide 8: Machine Learning Classifiers
*   **Slide Content**:
    *   **Multinomial Naive Bayes**: Frequencies conditional probabilities.
    *   **Logistic Regression**: Standard reference model with L2 regularization.
    *   **Passive Aggressive Classifier**: Incremental online learning; C-parameter optimization for error margins.
*   **Speaker Notes**: "We train three classifiers: Multinomial Naive Bayes for probabilistic baseline, Logistic Regression for linear regularized classification, and Passive Aggressive Classifier, which is ideal for streaming data feeds."

### 🎴 Slide 9: Weighted Voting Ensemble Formulation
*   **Slide Content**:
    *   Concept: Soft probability averaging.
    *   Formula: $P_{Ensemble} = w_1 \cdot P_{PAC} + w_2 \cdot P_{NB} + w_3 \cdot P_{LR}$
    *   Weights distribution: Passive Aggressive (45%), Naive Bayes (25%), Logistic Regression (30%).
*   **Speaker Notes**: "Our weighted ensemble averages prediction probabilities. PAC gets the highest weight (45%) due to its robustness against incremental shifts, followed by Logistic Regression and Naive Bayes."

### 🎴 Slide 10: Explainable AI: Attribution Highlighter
*   **Slide Content**:
    *   Math: Extracting weights from Logistic Regression coefficients (`model.coef_[0]`).
    *   Word mapping: Matching feature vocabulary indices to input tokens.
    *   Visual: Color intensities (Red spans = Fake indicators, Green spans = Real indicators).
*   **Speaker Notes**: "For explainability, we map the logistic regression coefficients to the original words. Positive weights indicate clickbait structures and are highlighted in Red. Negative weights indicate objective journalism and are highlighted in Green."

### 🎴 Slide 11: Web Application & SQLite Architecture
*   **Slide Content**:
    *   Stack: Flask backend, SQLAlchemy ORM.
    *   SQLite schema: `article_logs` table (timestamp, title, body, model, prediction, confidence, pre-rendered HTML).
    *   UI features: Modern dark theme, real-time uploads, search filters, and delete controls.
*   **Speaker Notes**: "The system is deployed as a Flask portal. Predictions, probabilities, and pre-rendered explainability maps are logged in an SQLite database, allowing users to query histories on the dashboard."

### 🎴 Slide 12: Quantitative Performance Benchmarks
*   **Slide Content**:
    *   Performance metrics table (evaluated on unseen test data):
        *   **Weighted Ensemble: ~95.8% Accuracy, ~95.4% Precision, ~96.2% Recall**
        *   Passive Aggressive: ~94.2% Accuracy
        *   Logistic Regression: ~93.3% Accuracy
        *   Naive Bayes: ~91.6% Accuracy
*   **Speaker Notes**: "Here are our quantitative benchmarks. The Weighted Ensemble achieves the highest accuracy at 95.8%, followed closely by Passive Aggressive at 94.2%. This confirms our soft-voting approach enhances performance."

### 🎴 Slide 13: Comparative Visual Charts
*   **Slide Content**:
    *   Display of model comparison bar charts.
    *   Confusion matrices for all 4 model configurations.
*   **Speaker Notes**: "These confusion matrices demonstrate that the ensemble model drastically reduces false negatives—critical in newsrooms where real news must not be flagged as fake."

### 🎴 Slide 14: System Limitations & Future Scope
*   **Slide Content**:
    *   *Limitations*: Out-of-vocabulary terms require model retraining.
    *   *Future Scope*:
        1. DistilBERT / Transformer model integration.
        2. Real-time URL scraping and fact-checking.
        3. Support for multi-lingual article evaluations.
*   **Speaker Notes**: "Currently, the model requires retraining for out-of-vocabulary terms. Future work includes integrating lightweight transformer embeddings like DistilBERT and adding multi-lingual support."

### 🎴 Slide 15: Summary & Key Contributions
*   **Slide Content**:
    *   Delivered a M.Tech-level explainable classification pipeline.
    *   Achieved high accuracy (~95.8%) using CPU-efficient architectures.
    *   Successfully implemented visual word attribution highlights (XAI).
    *   Created full-stack database logs dashboard workspace.
*   **Speaker Notes**: "In summary, the project successfully implements a high-accuracy, explainable, and resource-efficient system, bridging the gap between accuracy, latency, and model transparency. Thank you. I am ready for questions."
