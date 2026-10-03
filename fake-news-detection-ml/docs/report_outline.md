# Thesis Report Outline (M.Tech Final Thesis)
## Fake News Detection System Using NLP & Machine Learning

This document outlines the **7 chapters** required for the final **M.Tech Thesis / Project Report** submission.

---

## 📄 Chapter 1: Introduction
### 1.1 Societal Background
*   The expansion of social networks and the democratization of content publishing.
*   Misinformation, rumors, and coordinated disinformation campaigns.
*   Socio-economic and political impacts of unverified news distributions.
### 1.2 Motivation
*   Infeasibility of manual fact-checking at scale.
*   Need for low-latency, automated computer-aided verification tools.
*   Relevance of local, resource-efficient machine learning solutions.
### 1.3 Project Scope & Objectives
*   Develop a pre-processing NLP framework and TF-IDF feature space.
*   Train, compare, and serialize 3 standard ML models and a weighted ensemble.
*   Establish word-level attribution explainability (XAI) overlays.
*   Deploy a Flask application logging outputs into an SQLite database.
### 1.4 Thesis Organization
*   Overview of Chapters 2 through 7.

---

## 📑 Chapter 2: Literature Review
### 2.1 Traditional Fact-Checking
*   Manual fact-checking organizations (Snopes, Politifact) and their structural limits.
*   Rule-based pattern matching in textual databases.
### 2.2 Machine Learning in Natural Language Processing (NLP)
*   Tokenization, stemming vs. lemmatization, and lexical frequency mappings.
*   History of text classification: Bag-of-Words, TF-IDF, and Word Embeddings (Word2Vec, GloVe).
### 2.3 Supervised Classifiers in Sentiment & News Verification
*   Naive Bayes in spam and news filtering.
*   Passive Aggressive Classifiers in online incremental learning tasks.
*   Ensemble learning paradigms (Voting, Stacking).
### 2.4 Explainability in Natural Language Processing (XAI)
*   The black-box problem of high-dimensional ML vectors.
*   Review of Local Interpretable Model-agnostic Explanations (LIME) and SHAP.
*   Identified research gaps: Absence of real-time local attribution visualizations.

---

## 🛠️ Chapter 3: Data Ingestion & Preprocessing
### 3.1 News Corpus Ingestion
*   Dataset distributions: Factual reports vs. sensationalist/clickbait columns.
*   Stratification splits: Training (80%) vs. Testing (20%).
### 3.2 Preprocessing Pipeline Design
*   Case folding, special characters stripping, and lexical standardization.
*   Stopwords elimination using NLTK corpora.
*   WordNet Lemmatization (extracting absolute word roots).
### 3.3 Feature Extraction (TF-IDF)
*   Term Frequency-Inverse Document Frequency calculations.
*   N-gram configuration selection (unigrams and bigrams).
*   Restricting vocabulary to maximum features limit (5000) for training efficiency.

---

## 🤖 Chapter 4: Classifier Design & Implementation
### 4.1 Multinomial Naive Bayes Model
*   Bayesian probability, term occurrences likelihood, and Laplace smoothing alpha configs.
### 4.2 Logistic Regression Model
*   Sigmoid mapping, cross-entropy minimization, and L2 parameter regularization.
### 4.3 Passive Aggressive Classifier
*   Incremental online learning formulation, margin-based loss, and aggressiveness parameter C.
### 4.4 Weighted Voting Ensemble Model
*   Soft probability accumulation, weighted combination formula, and parameter grid optimization.

---

## 🔥 Chapter 5: Explainable NLP & Web App Architecture
### 5.1 Explainability Mapping (Text Highlights)
*   Extracting model coefficients from the Logistic Regression feature weights.
*   Normalizing weights relative to maximum coefficients.
*   Generating colored HTML spans based on word indicators (Red = Fake, Green = Real).
### 5.2 Flask Server Architecture
*   REST API endpoints design (`/predict`, `/dashboard`, `/compare`, `/api/delete`).
*   Inference memory cache management.
### 5.3 SQLite Database Design
*   Relational schema: `article_logs` table.
*   Integrating SQLAlchemy ORM queries and history lists.

---

## 📊 Chapter 6: Performance Evaluation & Results
### 6.1 Quantitative Analysis
*   Evaluation metrics definitions: Accuracy, Precision, Recall, F1-Score.
*   Tabular model performance comparison.
### 6.2 Visual Benchmarks
*   Confusion matrices analysis across all 4 configurations.
*   Analyzing model accuracies under diverse word lengths.
### 6.3 Explainability Case Studies
*   Verifying token highlights against human-annotated clickbait patterns.
*   Assessing the system under adversarial text modifications.

---

## 🏁 Chapter 7: Conclusions & Future Scope
### 7.1 Key Technical Contributions
*   High-accuracy, low-latency, and explainable local verification portal.
### 7.2 System Limitations
*   Sensitivity to out-of-vocabulary terms and long-term context changes.
### 7.3 Future Research Directions
*   Integration of transformer embeddings (BERT/DistilBERT), cross-lingual support, and automated URL scraping.
