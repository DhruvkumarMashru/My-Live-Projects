import os
import sys
import pickle
import json
import numpy as np
import pandas as pd
from pathlib import Path
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression, PassiveAggressiveClassifier
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix

# Insert project directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import PATHS, MODELS, VECTORIZER, DATASET
from src.data.data_preprocessing import clean_text, build_vectorizer
from src.evaluation.metrics import plot_comparison_chart, plot_confusion_matrix

def generate_synthetic_news_data(n_samples=1200):
    """
    Generates a high-quality synthetic dataset of news articles with structured text patterns 
    that ML models can learn from.
    """
    print(f"⚙️ Generating {n_samples} synthetic news records...")
    np.random.seed(42)
    
    # Vocabulary blocks for Fake News (Clickbait, sensationalist, exaggerated, conspiracy)
    fake_titles = [
        "SHOCKING SECRET: The government cure for cancer they hid from you!",
        "You won't believe what this Hollywood actor did last night!",
        "BREAKING: Alien spaceship spotted landing behind the White House!",
        "Miracle weight loss pill doctors don't want you to know about!",
        "CONSPIRACY: Landmark study proves the moon landing was filmed in Hollywood.",
        "URGENT: Global elite planning immediate lockdown next Tuesday!",
        "Secret society controls world bank, insider source reveals details.",
        "Shocking video shows politician taking massive bribes in public.",
        "Doctors stunned by this simple $5 trick to reverse aging overnight!",
        "Breaking: Major city's water supply poisoned, authorities hiding truth."
    ]
    
    fake_bodies = [
        "A secret whistleblower has leaked documents showing a massive cover-up by pharmaceutical giants who have possessed a full cure for cancer since 1995. Shares of major healthcare corporations are skyrocketing as politicians silent on public trials.",
        "Insiders caught this scandalous video on camera showing a prominent celebrity in a heated exchange that the media is trying to delete. Click here to watch before it gets taken down forever!",
        "Multiple eyewitnesses reported a metallic circular craft descending from the clouds, hovering over the lawn for three minutes before accelerating into orbit. NASA refuses to answer press queries, leading to speculation.",
        "This revolutionary organic capsule burns fat in your sleep without dieting. Clinical trials show individuals losing forty pounds in a week. Big Pharma is attempting to ban sales to protect insulin profit margins.",
        "Classified files released by a hacker group contain stage design prints and audio recordings proving the entire space race was simulated inside a high-security warehouse in Nevada to bankrupt foreign rivals.",
        "An anonymous memo circulating within security agencies suggests a simulated crisis will be used to enforce emergency laws. Citizens are urged to store food and withdraw all physical cash immediately.",
        "Leaked records from an offshore bank details transactions linking world leaders to a singular control board that meets annually in Switzerland to dictate inflation rates and trade wars.",
        "CCTV footage obtained by our network captures a high-ranking official stuffed envelope with cash from a shell corporation representative in exchange for state construction approvals.",
        "A localized plant extract when consumed with warm water acts as a cognitive booster and reverses cellular decay. Major food companies are buying farmland to monopolize the product.",
        "Local water distribution facilities detected high levels of dangerous chemicals, yet central administrations ordered operations to proceed normally to prevent mass panic before election seasons."
    ]
    
    # Vocabulary blocks for Real News (factual, objective, source-quoted, professional)
    real_titles = [
        "Federal Reserve announces interest rate hike to combat inflation.",
        "Parliament passes landmark environmental protection bill.",
        "New clinical study links regular exercise to improved cognitive health.",
        "City council approves $50 million investment for public transit extension.",
        "Global trade markets stabilize following bilateral trade agreement.",
        "Tech conglomerate announces restructuring plan, affecting 5% of workforce.",
        "Scientists deploy deep-sea submersibles to map unexplored trenches.",
        "Local health department reports decline in seasonal influenza cases.",
        "State university receives major research grant for renewable energy projects.",
        "National space agency launches new weather satellite into geostationary orbit."
    ]
    
    real_bodies = [
        "The Federal Reserve Board of Governors voted on Wednesday to raise the benchmark interest rate by a quarter point, citing persistent inflation pressures in core services and labor market tightness.",
        "Following three days of debate, lawmakers finalized a comprehensive regulation bill setting stricter carbon emission targets for heavy industry and allocating funds for regional reforestation initiatives.",
        "Researchers at the National Institute of Health published findings in the Journal of Medicine indicating adults who engage in moderate cardiovascular activity three times a week show higher neuron densities.",
        "The metropolitan transit authority confirmed a long-term capital budget approval to construct three new light-rail stations, aiming to connect suburban sectors to the commercial district by next autumn.",
        "Stock indexes rose slightly in European and Asian markets after negotiators signed a bilateral agricultural tariff agreement, resolving a three-month import dispute between the trading partners.",
        "The chief executive officer announced in a memorandum to staff that the corporation will consolidate redundant administrative roles to invest heavily in cloud infrastructure research divisions.",
        "An oceanographic research vessel initiated a two-month mapping mission in the Pacific, utilizing multi-beam sonar arrays to document topographical features of deep oceanic valleys.",
        "Epidemiological data released in the weekly surveillance report shows a fifteen percent drop in hospital admissions related to respiratory viruses, which health officials attribute to higher vaccination uptake.",
        "The Department of Energy approved a federal grant for engineering departments to prototype high-efficiency photovoltaic cells capable of generating power during low-solar winter conditions.",
        "A heavy-lift rocket successfully placed the advanced meteorological spacecraft into orbit on Sunday, providing forecasters with real-time infrared scans of severe storm formations over the coast."
    ]
    
    data = []
    
    # Generate Fake news samples
    for i in range(n_samples // 2):
        title = np.random.choice(fake_titles)
        body = np.random.choice(fake_bodies)
        # Add random variations to make articles unique
        random_padding = " Extra report details suggest that " + np.random.choice([
            "a secret organization is involved.", "insiders are highly worried.", 
            "the media is actively censoring this.", "this could change everything."
        ])
        text = title + " " + body + random_padding
        data.append({"text": text, "label": 1}) # 1 = Fake
        
    # Generate Real news samples
    for i in range(n_samples // 2):
        title = np.random.choice(real_titles)
        body = np.random.choice(real_bodies)
        random_padding = " According to the official spokesperson, " + np.random.choice([
            "the policy will take effect next quarter.", "further evaluations are scheduled.",
            "negotiators remain optimistic about outcomes.", "the project is funded publicly."
        ])
        text = title + " " + body + random_padding
        data.append({"text": text, "label": 0}) # 0 = Real
        
    df = pd.DataFrame(data)
    # Shuffle
    df = df.sample(frac=1, random_state=42).reset_index(drop=True)
    return df

def train_models():
    # 1. Setup folders
    PATHS["models_dir"].mkdir(parents=True, exist_ok=True)
    PATHS["reports_dir"].mkdir(parents=True, exist_ok=True)
    
    # 2. Get data
    csv_path = DATASET["file_path"]
    if not csv_path.exists():
        print(f"📁 Dataset CSV not found. Generating new dataset...")
        df = generate_synthetic_news_data()
        csv_path.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(csv_path, index=True, index_label="id")
        print(f"💾 Dataset CSV successfully saved to: {csv_path.name}")
    else:
        print(f"📖 Loading dataset from CSV: {csv_path.name}")
        df = pd.read_csv(csv_path)
    
    # 3. Preprocess text
    print("🧹 Cleaning text dataset (tokenizing, removing stopwords, lemmatizing)...")
    df['cleaned_text'] = df['text'].apply(clean_text)
    
    # Save processed text data
    processed_path = csv_path.parent.parent / "processed" / "cleaned_news_dataset.csv"
    processed_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(processed_path, index=False)
    print(f"💾 Cleaned dataset saved to: processed/{processed_path.name}")
    
    # 4. Ingest and save TF-IDF Vectorizer
    vectorizer_path = PATHS["models_dir"] / VECTORIZER["file"]
    vectorizer = build_vectorizer(df['cleaned_text'], vectorizer_path)
    
    # 5. Extract features
    X = vectorizer.transform(df['cleaned_text'])
    y = df['label'].values
    
    # 6. Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # 7. Model Training & Evaluation Dictionary
    metrics_report = {}
    trained_models = {}
    
    # Define models
    model_instances = {
        "pac": PassiveAggressiveClassifier(max_iter=50, random_state=42, C=0.8),
        "nb": MultinomialNB(alpha=0.5),
        "lr": LogisticRegression(max_iter=1000, random_state=42, C=1.0)
    }
    
    for key, model in model_instances.items():
        name = MODELS[key]["name"]
        print(f"🤖 Training model: {name}...")
        
        # Fit
        model.fit(X_train, y_train)
        
        # Predict
        y_pred = model.predict(X_test)
        
        # Calculate metrics
        acc = accuracy_score(y_test, y_pred)
        prec = precision_score(y_test, y_pred)
        rec = recall_score(y_test, y_pred)
        f1 = f1_score(y_test, y_pred)
        cm = confusion_matrix(y_test, y_pred).tolist()
        
        metrics_report[key] = {
            "accuracy": float(acc),
            "precision": float(prec),
            "recall": float(rec),
            "f1_score": float(f1),
            "confusion_matrix": cm,
            "total_samples": len(y_test)
        }
        
        # Save model
        model_path = PATHS["models_dir"] / MODELS[key]["file"]
        with open(model_path, "wb") as f:
            pickle.dump(model, f)
        print(f"   💾 Saved check-point to {model_path.name} | Accuracy: {acc*100:.2f}%")
        
        trained_models[key] = model
        
    # 8. Ensemble model configuration
    # For basic weighted ensemble prediction
    ensemble_path = PATHS["models_dir"] / MODELS["ensemble"]["file"]
    ensemble_meta = {
        "models": ["pac", "nb", "lr"],
        "weights": MODELS["ensemble"]["weights"]
    }
    
    with open(ensemble_path, "wb") as f:
        pickle.dump(ensemble_meta, f)
        
    # Evaluate Ensemble manually
    w = MODELS["ensemble"]["weights"]
    
    # Predict probabilities (or decision functions)
    # PAC decision function, NB predict_proba, LR predict_proba
    pac_decision = trained_models["pac"].decision_function(X_test)
    # Map decision function to pseudo-probabilities via sigmoid
    pac_probs = 1 / (1 + np.exp(-pac_decision))
    nb_probs = trained_models["nb"].predict_proba(X_test)[:, 1]
    lr_probs = trained_models["lr"].predict_proba(X_test)[:, 1]
    
    ensemble_probs = w[0]*pac_probs + w[1]*nb_probs + w[2]*lr_probs
    ensemble_preds = (ensemble_probs >= 0.5).astype(int)
    
    e_acc = accuracy_score(y_test, ensemble_preds)
    e_prec = precision_score(y_test, ensemble_preds)
    e_rec = recall_score(y_test, ensemble_preds)
    e_f1 = f1_score(y_test, ensemble_preds)
    e_cm = confusion_matrix(y_test, ensemble_preds).tolist()
    
    metrics_report["ensemble"] = {
        "accuracy": float(e_acc),
        "precision": float(e_prec),
        "recall": float(e_rec),
        "f1_score": float(e_f1),
        "confusion_matrix": e_cm,
        "total_samples": len(y_test)
    }
    print(f"🔮 Weighted Ensemble Configured | Accuracy: {e_acc*100:.2f}%")
    
    # Save metrics JSON report
    report_path = PATHS["reports_dir"] / "all_models_metrics.json"
    with open(report_path, "w") as f:
        json.dump(metrics_report, f, indent=4)
        
    print(f"📊 Model metrics database exported to {report_path}")
    
    # Generate metric charts
    print("📈 Generating comparative evaluation charts...")
    try:
        plot_comparison_chart(metrics_report)
        for key in ["pac", "nb", "lr", "ensemble"]:
            if key in metrics_report:
                plot_confusion_matrix(metrics_report[key]["confusion_matrix"], key)
        print("✅ Metric charts successfully saved to reports/")
    except Exception as e:
        print(f"⚠️ Failed to generate charts: {e}")
        
    print("🚀 Training complete!")

if __name__ == "__main__":
    train_models()
