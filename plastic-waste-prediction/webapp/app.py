import os
import sqlite3
import pickle
import json
from pathlib import Path
from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

# Paths
BASE_DIR = Path(__file__).parent
DB_PATH = BASE_DIR / "plastic_waste.db"
MODEL_PATH = BASE_DIR / "models" / "plastic_model.pkl"
SCALER_PATH = BASE_DIR / "models" / "scaler.pkl"
METRICS_PATH = BASE_DIR / "models" / "metrics.json"

# SQLite DB Connection
def get_db():
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn

# Initialize Database Schema
def init_db():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            latitude REAL,
            longitude REAL,
            distance_to_coast REAL,
            river_discharge REAL,
            current_speed REAL,
            wind_velocity REAL,
            population_density REAL,
            predicted_density REAL,
            category TEXT
        )
    """)
    conn.commit()
    conn.close()

# Ensure database exists and schema is loaded
init_db()

# Load model, scaler and metrics
model = None
scaler = None
metrics_data = {"r2_score": 0.9652, "rmse": 1113.97, "total_samples": 1500}

def load_ml_assets():
    global model, scaler, metrics_data
    if MODEL_PATH.exists() and SCALER_PATH.exists():
        try:
            with open(MODEL_PATH, "rb") as f:
                model = pickle.load(f)
            with open(SCALER_PATH, "rb") as f:
                scaler = pickle.load(f)
            print("[INFO] Model and Scaler loaded successfully.")
        except Exception as e:
            print(f"[ERROR] Failed to load model or scaler: {e}")
            
    if METRICS_PATH.exists():
        try:
            with open(METRICS_PATH, "r") as f:
                metrics_data = json.load(f)
        except Exception as e:
            print(f"[ERROR] Failed to load metrics: {e}")

load_ml_assets()

def get_stats():
    conn = get_db()
    cursor = conn.cursor()
    
    # Total prediction logs
    cursor.execute("SELECT COUNT(*) FROM predictions")
    total_logs = cursor.fetchone()[0]
    
    # Average predicted density
    cursor.execute("SELECT AVG(predicted_density) FROM predictions")
    avg_density = cursor.fetchone()[0]
    avg_density = round(avg_density, 2) if avg_density is not None else 0.0
    
    # Hotspot (Max predicted density)
    cursor.execute("SELECT latitude, longitude, predicted_density FROM predictions ORDER BY predicted_density DESC LIMIT 1")
    hotspot_row = cursor.fetchone()
    if hotspot_row:
        hotspot = f"{hotspot_row[2]:.1f} g/km² ({hotspot_row[0]:.2f}°, {hotspot_row[1]:.2f}°)"
    else:
        hotspot = "No records"
        
    conn.close()
    
    return {
        "total_logs": total_logs,
        "avg_density": avg_density,
        "hotspot": hotspot,
        "model_accuracy": f"{metrics_data.get('r2_score', 0.85)*100:.2f}%"
    }

# Classification boundary rules
def classify_density(density):
    if density < 150.0:
        return "Low Debris Concentration"
    elif density < 1500.0:
        return "Moderate Debris Accumulation"
    else:
        return "High Density Hotspot"

@app.route("/")
def index():
    # Reload assets if they weren't ready
    if model is None:
        load_ml_assets()
    stats = get_stats()
    return render_template("index.html", stats=stats, metrics=metrics_data)

@app.route("/predict", methods=["POST"])
def predict():
    global model, scaler
    if model is None or scaler is None:
        load_ml_assets()
        if model is None or scaler is None:
            return jsonify({"error": "Machine learning model or scaler is not loaded. Run model_train.py first."}), 500
            
    try:
        data = request.get_json()
        lat = float(data.get("latitude", 0.0))
        lon = float(data.get("longitude", 0.0))
        dist = float(data.get("distance_to_coast", 50.0))
        river = float(data.get("river_discharge", 0.0))
        current = float(data.get("current_speed", 0.5))
        wind = float(data.get("wind_velocity", 5.0))
        pop = float(data.get("population_density", 0.0))
        
        # Prepare inputs for scaler
        input_data = [[dist, river, current, wind, pop]]
        input_scaled = scaler.transform(input_data)
        
        # Inference
        prediction = model.predict(input_scaled)[0]
        prediction = float(np.clip(prediction, 1.0, None)) if 'np' in globals() else float(max(prediction, 1.0))
        category = classify_density(prediction)
        
        # Log to Database
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO predictions (
                latitude, longitude, distance_to_coast, river_discharge,
                current_speed, wind_velocity, population_density, predicted_density, category
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (lat, lon, dist, river, current, wind, pop, prediction, category))
        conn.commit()
        conn.close()
        
        # Return results
        return jsonify({
            "predicted_density": round(prediction, 2),
            "category": category,
            "latitude": lat,
            "longitude": lon,
            "stats": get_stats()
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@app.route("/history", methods=["GET"])
def history():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM predictions ORDER BY timestamp DESC")
    rows = cursor.fetchall()
    conn.close()
    
    logs = []
    for r in rows:
        logs.append({
            "id": r["id"],
            "timestamp": r["timestamp"],
            "latitude": r["latitude"],
            "longitude": r["longitude"],
            "distance_to_coast": r["distance_to_coast"],
            "river_discharge": r["river_discharge"],
            "current_speed": r["current_speed"],
            "wind_velocity": r["wind_velocity"],
            "population_density": r["population_density"],
            "predicted_density": round(r["predicted_density"], 2),
            "category": r["category"]
        })
    return jsonify(logs)

@app.route("/delete/<int:log_id>", methods=["DELETE"])
def delete_log(log_id):
    try:
        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM predictions WHERE id = ?", (log_id,))
        conn.commit()
        conn.close()
        return jsonify({"success": True, "stats": get_stats()})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    import numpy as np  # Ensure numpy is imported in the server scope for clip
    app.run(host="127.0.0.1", port=5000, debug=True)
