# VeriTrack AI — Step-by-Step System Deployment & User Guide
## Fake News Detection System Using NLP & Machine Learning

---

## 💻 System Requirements & Stack
- **Operating System**: Windows 10/11 (with Command Prompt/PowerShell support)
- **Language**: Python 3.9+ (64-bit version recommended)
- **NLP Libraries**: NLTK (requires `stopwords`, `wordnet`, and `punkt` corpora)
- **ML Frameworks**: Scikit-Learn (regression and classification tools), Pandas, NumPy
- **Web stack**: Flask, Flask-SQLAlchemy, SQLite3 database, Chart.js, Vanilla CSS & JS
- **Hardware baseline**: 4GB System RAM, modern standard CPU (inference completes locally in <100ms)

---

## 🚀 Stepwise System Operations

### 📦 Step 1: Environment Setup
The project features an automated launcher (`setup_env.bat`) which configures virtual environments and packages dependencies.

1. Open a Command Prompt or PowerShell terminal in the project root directory:
   ```powershell
   cd e:\PROJECT\fake_news_detection
   ```
2. Launch the setup batch script:
   ```powershell
   .\setup_env.bat
   ```
3. Select **Option [1]** to install required libraries (`pip install -r requirements.txt`).
4. Select **Option [2]** to download NLTK datasets. This downloads the `stopwords`, `wordnet`, and `punkt` corpora directly into the local `nltk_data/` directory to keep the project self-contained.

---

### 🤖 Step 2: Model Training & Benchmark Serialization
1. From the launcher menu, select **Option [3]** (or run `python src/training/train_models.py` directly).
2. This script:
   *   Generates a synthetic dataset of 1,200 news articles containing structured vocabulary patterns.
   *   Preprocesses text (cleans, tokenizes, removes stopwords, lemmatizes).
   *   Extracts n-gram TF-IDF matrices.
   *   Trains and saves **Passive Aggressive, Naive Bayes, and Logistic Regression** model checkpoints.
   *   Computes and saves performance metrics in `reports/all_models_metrics.json`.
   *   Generates and exports comparative accuracy bar charts and model confusion matrices in the `reports/` folder.

---

### 🌐 Step 3: Launching the Web Workspace
1. Launch the batch tool and select **Option [4]** (or run `python run.py`).
2. Open your web browser and navigate to: **`http://127.0.0.1:5000`**
3. *Fallback Sandbox Note*: If the machine learning models have not been trained yet, the application automatically boots into **Demo Sandbox Mode**, using pre-seeded news patterns to simulate classifications and HTML keyword highlights.

---

## 🖥️ Clinician/User App Walkthrough

### 1. Headline & Article Verification
1. Navigate to the **Analyze Text** workspace from the navigation bar.
2. Enter the Headline title (optional) and paste the body text of a news article into the textarea.
3. Select the desired AI model from the dropdown list. The **Weighted Voting Ensemble** is selected by default and offers the highest classification accuracy.
4. Click **Verify Authenticity**. The backend executes standard NLP pre-processing, performs real-time classification, and returns:
   *   The verdict: **FAKE** (in red) or **REAL** (in green).
   *   The prediction confidence percentage.
   *   The **NLP Attribution Map**: The pasted article text is rendered with highlighted words. Clickbait words are highlighted in Red (strength proportional to coefficient), and factual words are highlighted in Green.

### 2. Database Logs Dashboard
1. Select **Dashboard Logs** from the navigation bar.
2. Review aggregated metrics: Total scanned articles, total fake flagged count, and total genuine verified count.
3. Search and filter prediction history logs using the search bar (filter by title keywords, model used, or status verdicts).
4. View the highlighted attribution maps of historical predictions directly inside the logs table.
5. Delete specific log entries from the SQLite database by clicking the trash-can icon.

### 3. Model Benchmark Comparisons
1. Click **Benchmark Models** in the navigation bar.
2. Compare accuracies, F1-scores, and confusion matrices (True Positive/Negative rates) of the Passive Aggressive, Naive Bayes, Logistic Regression, and Ensemble models side-by-side.

---

## 🛠️ Troubleshooting & Diagnostics

- **NLTK Lookup Errors**:
  If the application fails with a `LookupError` regarding stopwords or wordnet, run Option [2] in `setup_env.bat` to download the NLTK corpora to the local `nltk_data/` folder.
- **Database Reset**:
  To clear prediction history logs and reset the database seed data, delete the database file at `webapp/fake_news.db`. The Flask application will automatically re-create the tables and seed mock data on the next launch.
- **Missing Models Warning**:
  If the app indicates "Untrained Fallback," run Option [3] in `setup_env.bat` to train the models and export serialized model assets (`.pkl`) to the `models/` directory.
