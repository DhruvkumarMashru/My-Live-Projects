import re
import nltk
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from sklearn.feature_extraction.text import TfidfVectorizer
import pickle
import sys
from pathlib import Path

# Insert project directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import PATHS, VECTORIZER

# Initialize NLTK structures
lemmatizer = WordNetLemmatizer()

def clean_text(text: str) -> str:
    """
    Standard text preprocessing pipeline:
    1. Lowercase conversion
    2. Removal of non-alphabetic characters
    3. Tokenization
    4. Stopwords removal
    5. WordNet Lemmatization
    """
    if not isinstance(text, str):
        return ""
    
    # 1. Lowercase
    text = text.lower()
    
    # 2. Keep only letters
    text = re.sub(r'[^a-z\s]', '', text)
    
    # 3. Tokenize
    words = text.split()
    
    # 4 & 5. Filter stopwords and Lemmatize
    stop_words = set(stopwords.words('english'))
    cleaned_words = [
        lemmatizer.lemmatize(word) for word in words 
        if word not in stop_words and len(word) > 2
    ]
    
    # Re-join
    return " ".join(cleaned_words)

def build_vectorizer(corpus, save_path=None):
    """Fits and saves a TF-IDF Vectorizer on a text corpus."""
    vectorizer = TfidfVectorizer(
        max_features=VECTORIZER["max_features"],
        ngram_range=VECTORIZER["ngram_range"],
        stop_words='english'
    )
    vectorizer.fit(corpus)
    
    if save_path:
        with open(save_path, "wb") as f:
            pickle.dump(vectorizer, f)
        print(f"💾 Vectorizer successfully saved to {save_path.name}")
        
    return vectorizer

def load_vectorizer(path=None):
    """Loads a serialized TF-IDF vectorizer from disk."""
    load_path = path or (PATHS["models_dir"] / VECTORIZER["file"])
    with open(load_path, "rb") as f:
        vectorizer = pickle.load(f)
    return vectorizer
