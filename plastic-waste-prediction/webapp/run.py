import os
import sys
from pathlib import Path

def main():
    base_dir = Path(__file__).parent
    model_path = base_dir / "models" / "plastic_model.pkl"
    scaler_path = base_dir / "models" / "scaler.pkl"
    
    # Check if models are trained, if not train them
    if not model_path.exists() or not scaler_path.exists():
        print("[WARN] Serialized models not found. Running training process...")
        train_script = base_dir / "model_train.py"
        os.system(f"python {train_script}")
        
    print("[INFO] Launching Ocean Sentry AI Flask dashboard...")
    sys.path.insert(0, str(base_dir))
    
    from app import app
    app.run(host="127.0.0.1", port=5000, debug=True)

if __name__ == "__main__":
    main()
