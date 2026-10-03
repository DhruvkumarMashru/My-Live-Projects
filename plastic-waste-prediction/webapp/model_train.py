import os
import pickle
from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score, mean_squared_error

def train_model():
    print("[INFO] Starting synthetic data generation for Ocean Plastic Waste...")
    np.random.seed(42)
    
    # Generate 1500 realistic data points
    n_samples = 1500
    
    # Features
    lat = np.random.uniform(-90.0, 90.0, n_samples)
    lon = np.random.uniform(-180.0, 180.0, n_samples)
    distance_to_coast = np.random.exponential(scale=50.0, size=n_samples) + 0.1  # km
    river_discharge = np.random.exponential(scale=100.0, size=n_samples) * np.random.choice([0, 1], size=n_samples, p=[0.3, 0.7])  # m3/s
    current_speed = np.random.uniform(0.05, 2.0, n_samples)  # m/s
    wind_velocity = np.random.uniform(0.5, 18.0, n_samples)  # m/s
    population_density = np.random.exponential(scale=1500.0, size=n_samples) * (distance_to_coast < 30.0)  # coastal population
    population_density = np.clip(population_density, 0, 15000)
    
    # Calculate non-linear plastic waste density (g/km2)
    # Debris is higher near coastlines with high population, near major river mouths, and in high current accumulation zones
    base_density = (
        (35.0 * population_density / (distance_to_coast + 0.5)) +
        (15.0 * river_discharge / (distance_to_coast + 1.0)) +
        (120.0 * np.log(current_speed + 1.0)) +
        (5.0 * wind_velocity) +
        15.0
    )
    
    # Add heteroscedastic noise
    noise = np.random.normal(0, 0.15 * base_density + 5.0, n_samples)
    plastic_density = np.clip(base_density + noise, 1.0, 25000.0) # g/km2
    
    # Create DataFrame
    df = pd.DataFrame({
        'latitude': lat,
        'longitude': lon,
        'distance_to_coast': distance_to_coast,
        'river_discharge': river_discharge,
        'current_speed': current_speed,
        'wind_velocity': wind_velocity,
        'population_density': population_density,
        'plastic_density': plastic_density
    })
    
    print(f"[INFO] Generated {n_samples} spatial data rows.")
    print(df.describe())
    
    # Features and labels
    X = df[['distance_to_coast', 'river_discharge', 'current_speed', 'wind_velocity', 'population_density']]
    y = df['plastic_density']
    
    # Split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Scaling
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Model
    print("[INFO] Training Random Forest Regressor...")
    model = RandomForestRegressor(n_estimators=100, max_depth=12, random_state=42, n_jobs=-1)
    model.fit(X_train_scaled, y_train)
    
    # Predict
    y_pred = model.predict(X_test_scaled)
    r2 = r2_score(y_test, y_pred)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    
    print(f"[SUCCESS] Model Evaluation:")
    print(f"  R2 Score:  {r2:.4f}")
    print(f"  RMSE:      {rmse:.4f} g/km2")
    
    # Save artifacts
    models_dir = Path(__file__).parent / "models"
    models_dir.mkdir(exist_ok=True)
    
    model_path = models_dir / "plastic_model.pkl"
    scaler_path = models_dir / "scaler.pkl"
    
    with open(model_path, "wb") as f:
        pickle.dump(model, f)
    with open(scaler_path, "wb") as f:
        pickle.dump(scaler, f)
        
    print(f"[SUCCESS] Saved model to: {model_path}")
    print(f"[SUCCESS] Saved scaler to: {scaler_path}")
    
    # Also save evaluation metrics to a json file for the dashboard to display
    import json
    metrics = {
        "r2_score": float(r2),
        "rmse": float(rmse),
        "total_samples": n_samples,
        "features": list(X.columns)
    }
    with open(models_dir / "metrics.json", "w") as f:
        json.dump(metrics, f, indent=4)
        
    print("[INFO] Model training workflow completed.")

if __name__ == "__main__":
    train_model()
