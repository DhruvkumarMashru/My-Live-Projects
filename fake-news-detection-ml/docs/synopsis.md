# Project Synopsis (M.Tech Phase I & II)
## Fake News Detection System Using Natural Language Processing & Machine Learning
### An Explainable Artificial Intelligence Approach

---

**Investigator   :** Master of Technology (M.Tech) Candidate  
**Stream         :** Computer Science & Engineering / Artificial Intelligence & Data Science  
**Department     :** Department of Computer Science and Engineering  
**Supervisor     :** Project Research Advisor & Faculty Head  

---

## 1. Introduction
With the exponential rise of online news dissemination platforms, social networks, and blogs, the rapid spread of misinformation, rumors, and fake news has emerged as a major societal challenge. Misinformation can sway democratic processes, disrupt economic markets, and spark public panic. Manually verifying every digital publication is infeasible due to the sheer volume of daily articles, necessitating automated, high-fidelity classification tools.

This project proposes a **Fake News Detection System** utilizing Natural Language Processing (NLP) and Machine Learning (ML) techniques. The system is designed to preprocess raw news text and evaluate it against multiple machine learning classifiers to determine its validity. Crucially, the system implements **Explainable AI (XAI)** principles, extracting model weights to highlight specific textual tokens that contribute to classification verdicts, thus establishing trust for the end-user.

---

## 2. Problem Statement
Automating text-based fake news identification is challenging due to:
- **Semantic Nuance**: Clickbait headlines and sensationalist stories use highly deceptive vocabulary.
- **Explainability Deficits**: Most ML/DL classifiers behave as "black boxes," leaving users unsure of *why* an article was categorized as fake.
- **Resource Constraints**: High-capacity Deep Learning models (like Transformers/LLMs) require massive VRAM and compute power, which are unavailable in budget-constrained newsrooms.
This project tackles these challenges by designing a lightweight, explainable, and multi-model benchmark suite optimized for fast local CPU/GPU execution.

---

## 3. Objectives
1. **Pipeline Construction**: Develop a structured NLP pipeline for cleaning, lemmatizing, and standardizing raw text articles.
2. **Feature Engineering**: Implement n-gram TF-IDF (Term Frequency-Inverse Document Frequency) vectorization to capture semantic word associations.
3. **Multi-Model Benchmarking**: Evaluate and serialize three models: Multinomial Naive Bayes, Logistic Regression, and a Passive Aggressive Classifier.
4. **Ensemble Architecture**: Implement a Weighted Voting Ensemble model combining probability forecasts to maximize classification accuracy.
5. **XAI Integration**: Map model weights and TF-IDF coefficients back to the input words, creating a visual highlighting engine.
6. **Full-Stack Clinician/User Workspace**: Build a Flask app integrated with an SQLite database database to log and query histories.

---

## 4. Methodology & Models

### 4.1 Preprocessing Workflow
- **Standardization**: Conversion to lowercase, removal of special character encodings.
- **Tokenization & Stopwords Removal**: Split text blocks into word lists and filter out structural English words (e.g. "and", "the").
- **WordNet Lemmatization**: Convert inflected words (e.g. "ran", "running") to their dictionary root form ("run").
- **Vectorization**: Transform processed tokens into numeric matrices using unigram and bigram TF-IDF configurations.

### 4.2 Machine Learning Classifiers
1. **Passive Aggressive Classifier (PAC)**: Online learning model designed for streaming data feeds; aggressively updates coefficients on classification errors.
2. **Multinomial Naive Bayes (NB)**: High-speed probabilistic baseline classifier calculating word counts.
3. **Logistic Regression (LR)**: Fills feature spaces with regularized boundaries; exports probability estimates.
4. **Voting Ensemble**: Uses a weighted average of individual classifier probabilities to determine the final label.

---

## 5. System Architecture
```
[Raw Article Text Input]
          ↓
[NLTK Preprocessing: Tokenize, Stopwords, Lemmatize]
          ↓
[TF-IDF N-Gram Vectorizer Matrix]
          ↓
┌───────────────────────┼────────────────────────┐
↓                       ↓                        ↓
[PAC Model]        [Naive Bayes]       [Logistic Regression]
└───────────────────────┼────────────────────────┘
                        ↓ (Weighted Probabilities)
               [Weighted Ensemble]
                        ↓
            [Classification: FAKE / REAL]
                        +
          [Word Attribution Heatmap (XAI)]
                        ↓
             [SQLite Log Persistence]
```

---

## 6. Expected Outcomes
- **Classification Accuracy**: Weighted Ensemble targeting **≥95% accuracy** on unseen validation datasets.
- **Attribution Explanations**: Accurate highlight overlaps (Red for clickbait signals, Green for objective indicators).
- **Resource Footprint**: Server loading and inference completing in **<100ms** on standard CPUs.
- **Database Registries**: Dynamic SQLite database table integrations to query historical records.
