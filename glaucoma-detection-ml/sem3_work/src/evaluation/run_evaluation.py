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
from src.training.model_transfer import build_vgg16_model
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

# SQLite updates disabled for Semester 3

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
            
            print("\n🎉 Evaluation complete. All charts saved in 'reports/' directory.")
        except Exception as e:
            print(f"❌ Error saving reports/charts: {e}")
    else:
        print("\n❌ No models were evaluated. No reports generated.")

if __name__ == "__main__":
    main()
