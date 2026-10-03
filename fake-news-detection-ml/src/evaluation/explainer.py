import sys
import pickle
import numpy as np
from pathlib import Path
from nltk.stem import WordNetLemmatizer

# Insert project directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import PATHS, MODELS, VECTORIZER
from src.data.data_preprocessing import clean_text

class NLPExplainer:
    """
    Explainable NLP module. Extracts model coefficients to map feature weights 
    back to the original words in a text block, generating an HTML-formatted explanation visualization.
    """
    
    def __init__(self):
        self.model = None
        self.vectorizer = None
        self.word_weights = {}
        self.lemmatizer = WordNetLemmatizer()
        self.load_assets()
        
    def load_assets(self):
        """Loads Logistic Regression model and TF-IDF vectorizer to extract text coefficients."""
        model_path = PATHS["models_dir"] / MODELS["lr"]["file"]
        vec_path = PATHS["models_dir"] / VECTORIZER["file"]
        
        if not model_path.exists() or not vec_path.exists():
            print("[WARNING] Explainer assets not loaded. Run train_models.py first.")
            return False
            
        with open(model_path, "rb") as f:
            self.model = pickle.load(f)
        with open(vec_path, "rb") as f:
            self.vectorizer = pickle.load(f)
            
        # Extract features and map weights
        feature_names = self.vectorizer.get_feature_names_out()
        coefficients = self.model.coef_[0]
        
        self.word_weights = {
            word: float(coef) for word, coef in zip(feature_names, coefficients)
        }
        return True
        
    def explain_text(self, text: str) -> str:
        """
        Processes a text string and generates a color-highlighted HTML string:
        - Words indicating FAKE news highlighted in RED (positive coefficients).
        - Words indicating REAL news highlighted in GREEN (negative coefficients).
        """
        if not self.word_weights:
            if not self.load_assets():
                return f"<p>{text}</p>" # Fallback if model not trained
                
        # Split text into original tokens while maintaining formatting/punctuation
        tokens = text.split()
        html_tokens = []
        
        # Determine maximum coefficient for color normalization scale
        coef_values = list(self.word_weights.values())
        max_val = max(abs(min(coef_values)), max(coef_values)) if coef_values else 1.0
        if max_val == 0:
            max_val = 1.0
            
        for token in tokens:
            # Clean token to query vocabulary (convert to lowercase, strip punctuation, lemmatize)
            clean_token = token.lower().strip(".,!?;:()[]\"'")
            lemma_token = self.lemmatizer.lemmatize(clean_token)
            
            # Check weight
            weight = 0.0
            if lemma_token in self.word_weights:
                weight = self.word_weights[lemma_token]
            elif clean_token in self.word_weights:
                weight = self.word_weights[clean_token]
                
            # Formatting spans based on weights
            if weight > 0.05: # Indicator for Fake (Red)
                intensity = min(float(weight / max_val) * 0.75 + 0.15, 0.9)
                span = f'<span class="explain-token fake-hl" style="background-color: rgba(255, 51, 102, {intensity:.3f}); color: white; padding: 2px 4px; border-radius: 4px; font-weight: 500;" title="Fake Indicator (Score: +{weight:.3f})">{token}</span>'
            elif weight < -0.05: # Indicator for Real (Green)
                intensity = min(float(abs(weight) / max_val) * 0.75 + 0.15, 0.9)
                span = f'<span class="explain-token real-hl" style="background-color: rgba(0, 230, 118, {intensity:.3f}); color: white; padding: 2px 4px; border-radius: 4px; font-weight: 500;" title="Real Indicator (Score: {weight:.3f})">{token}</span>'
            else:
                span = token
                
            html_tokens.append(span)
            
        return " ".join(html_tokens)

if __name__ == "__main__":
    explainer = NLPExplainer()
    test_article = "SHOCKING SECRET: Alien spaceship landed in city and government is hiding cures!"
    html_res = explainer.explain_text(test_article)
    print("HTML Explainer output:")
    print(html_res)
