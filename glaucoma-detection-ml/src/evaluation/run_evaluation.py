"""
======================================================================
  Evaluation Runner Script
======================================================================
  Loads all 5 trained models (CNN, VGG16, ResNet50, EfficientNetB0, 
  and Ensemble), runs test-set evaluation, generates confusion 
  matrices, ROC curves, comparative charts, saves JSON reports, 
  and updates the SQLite database with the actual performance metrics.
======================================================================
"""

import sys
import json
import sqlite3
import time
from pathlib import Path
from datetime import datetime

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
from tqdm import tqdm

# Project root
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import PATHS, DEVICE, MODELS, DATASET

from src.data.dataset_loader import get_dataloaders
from src.training.model_cnn import build_cnn_model
from src.training.model_transfer import (
    build_vgg16_model, build_resnet50_model, build_efficientnet_model
)
from src.training.model_ensemble import load_ensemble
from src.evaluation.metrics import (
    compute_metrics, plot_confusion_matrix, plot_roc_curves,
    plot_comparison_chart, plot_sensitivity_specificity,
    print_comparison_table, save_metrics_report
)

def evaluate_model_on_test(model: nn.Module, loader, device) -> tuple:
    """Run inference over the loader to get labels, predictions, and probabilities."""
    model.eval()
    all_preds = []
    all_labels = []
    all_probs = []
    
    with torch.no_grad():
        for images, labels in tqdm(loader, desc="  Evaluating", leave=False, ncols=90):
            images = images.to(device)
            outputs = model(images)
            probs = F.softmax(outputs, dim=1)
            preds = outputs.argmax(dim=1)
            
            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.numpy())
            all_probs.extend(probs.cpu().numpy())
            
    return np.array(all_labels), np.array(all_preds), np.array(all_probs)

def update_db_metrics(all_metrics: dict, db_path: Path):
    """Directly updates the model_metrics table in SQLite database."""
    print(f"\n🌱 Updating SQLite database metrics at {db_path}...")
    try:
        conn = sqlite3.connect(str(db_path))
        cursor = conn.cursor()
        
        # Ensure the table is created
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS model_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                model_name TEXT UNIQUE NOT NULL,
                accuracy REAL,
                precision REAL,
                recall REAL,
                f1_score REAL,
                auc_roc REAL,
                sensitivity REAL,
                specificity REAL,
                trained_date TEXT
            )
        """)
        
        for model_name, m in all_metrics.items():
            # Calculate values
            accuracy = float(m.get("accuracy", 0))
            precision = float(m.get("precision", 0))
            recall = float(m.get("recall", 0))
            f1_score = float(m.get("f1_score", 0))
            auc_roc = float(m.get("auc_roc", 0)) if m.get("auc_roc") is not None else None
            sensitivity = float(m.get("sensitivity", 0)) if m.get("sensitivity") is not None else None
            specificity = float(m.get("specificity", 0)) if m.get("specificity") is not None else None
            trained_date = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
            
            cursor.execute("""
                INSERT OR REPLACE INTO model_metrics 
                (model_name, accuracy, precision, recall, f1_score, auc_roc, sensitivity, specificity, trained_date)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (model_name, accuracy, precision, recall, f1_score, auc_roc, sensitivity, specificity, trained_date))
            
        conn.commit()
        conn.close()
        print("✅ SQLite database metrics table successfully updated.")
    except Exception as e:
        print(f"❌ Failed to update SQLite database: {e}")

def main():
    print("======================================================================")
    print("  🚀 Retinal OCT Glaucoma Detection - Model Evaluation Suite")
    print("======================================================================")
    print(f"  Device: {DEVICE}")
    
    # ── Load Dataloaders ──────────────────────────────────────────────
    print("\n📦 Loading dataloaders...")
    _, _, test_loader = get_dataloaders()
    
    # ── Models to Load ────────────────────────────────────────────────
    model_configs = {
        "cnn":          {"builder": build_cnn_model,          "file": "model_cnn.pth"},
        "vgg16":        {"builder": build_vgg16_model,        "file": "model_vgg16.pth"},
        "resnet50":     {"builder": build_resnet50_model,     "file": "model_resnet50.pth"},
        "efficientnet": {"builder": build_efficientnet_model, "file": "model_efficientnet.pth"},
    }
    
    loaded_models = {}
    all_metrics = {}
    
    # 1. Evaluate Individual Models
    for name, cfg in model_configs.items():
        weight_path = PATHS["models_dir"] / cfg["file"]
        if not weight_path.exists():
            print(f"⚠️  Weight file not found for {name}: {weight_path.name}. Skipping evaluation.")
            continue
            
        print(f"\n🤖 Loading and evaluating model: {name.upper()}...")
        try:
            model = cfg["builder"]().to(DEVICE)
            checkpoint = torch.load(weight_path, map_location=DEVICE)
            if isinstance(checkpoint, dict) and "model_state_dict" in checkpoint:
                model.load_state_dict(checkpoint["model_state_dict"])
            else:
                model.load_state_dict(checkpoint)
                
            y_true, y_pred, y_prob = evaluate_model_on_test(model, test_loader, DEVICE)
            
            # Compute metrics
            m = compute_metrics(y_true, y_pred, y_prob)
            all_metrics[name] = m
            loaded_models[name] = weight_path
            
            print(f"   Accuracy   : {m['accuracy']*100:.2f}%")
            if m.get('auc_roc') is not None:
                print(f"   AUC-ROC    : {m['auc_roc']:.4f}")
                
            # Plot confusion matrix
            plot_confusion_matrix(np.array(m["confusion_matrix"]), name)
            
        except Exception as e:
            print(f"❌ Error evaluating {name}: {e}")
            
    # 2. Evaluate Ensemble Model
    if len(loaded_models) >= 2:
        # Load transfer learning models specifically for ensemble
        ensemble_paths = {}
        for name in ["resnet50", "efficientnet", "vgg16"]:
            if name in loaded_models:
                ensemble_paths[name] = loaded_models[name]
                
        if len(ensemble_paths) >= 2:
            print("\n🔮 Creating and evaluating Ensemble model...")
            try:
                ensemble = load_ensemble(ensemble_paths, DEVICE)
                
                # Evaluation
                ensemble.eval()
                all_preds = []
                all_labels = []
                all_probs = []
                
                with torch.no_grad():
                    for images, labels in tqdm(test_loader, desc="  Evaluating", leave=False, ncols=90):
                        images = images.to(DEVICE)
                        log_probs = ensemble(images)
                        probs = torch.exp(log_probs)
                        preds = log_probs.argmax(dim=1)
                        
                        all_preds.extend(preds.cpu().numpy())
                        all_labels.extend(labels.numpy())
                        all_probs.extend(probs.cpu().numpy())
                        
                y_true = np.array(all_labels)
                y_pred = np.array(all_preds)
                y_prob = np.array(all_probs)
                
                # Compute metrics
                m = compute_metrics(y_true, y_pred, y_prob)
                all_metrics["ensemble"] = m
                
                print(f"   Ensemble Acc : {m['accuracy']*100:.2f}%")
                if m.get('auc_roc') is not None:
                    print(f"   Ensemble AUC : {m['auc_roc']:.4f}")
                    
                # Plot confusion matrix
                plot_confusion_matrix(np.array(m["confusion_matrix"]), "ensemble")
                
            except Exception as e:
                print(f"❌ Error creating/evaluating ensemble: {e}")
        else:
            print("\n⚠️  Not enough transfer learning models available to build ensemble.")
    else:
        print("\n⚠️  Not enough individual models available to build ensemble.")
        
    # ── Plot Comparisons and Save Reports ─────────────────────────────
    if len(all_metrics) > 0:
        print("\n📊 Generating overall performance comparison plots...")
        try:
            plot_roc_curves(all_metrics)
            plot_comparison_chart(all_metrics)
            plot_sensitivity_specificity(all_metrics)
            
            # Print table
            print_comparison_table(all_metrics)
            
            # Save combined report JSON
            save_metrics_report(all_metrics)
            
            # Update SQLite database
            update_db_metrics(all_metrics, PATHS["db_path"])
            
            print("\n🎉 Evaluation complete. All charts saved in 'reports/' directory.")
        except Exception as e:
            print(f"❌ Error saving reports/charts: {e}")
    else:
        print("\n❌ No models were evaluated. No reports generated.")

if __name__ == "__main__":
    main()
