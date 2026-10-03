import os
import sys
import json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, roc_curve, auc

# Insert project directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import PATHS, MODELS

def plot_confusion_matrix(cm, model_key, save_dir=None):
    """Plots and saves confusion matrix for a model."""
    save_dir = save_dir or PATHS["reports_dir"]
    save_dir.mkdir(parents=True, exist_ok=True)
    
    name = MODELS[model_key]["name"]
    fig, ax = plt.subplots(figsize=(6, 5))
    
    # Custom colored grid
    im = ax.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
    ax.figure.colorbar(im, ax=ax)
    
    # Classes labels
    classes = ["Real", "Fake"]
    ax.set(xticks=np.arange(len(classes)),
           yticks=np.arange(len(classes)),
           xticklabels=classes, yticklabels=classes,
           title=f"Confusion Matrix - {name}",
           ylabel="True Label",
           xlabel="Predicted Label")
    
    # Grid lines and text labels
    thresh = np.max(cm) / 2.
    for i in range(2):
        for j in range(2):
            ax.text(j, i, format(cm[i][j], 'd'),
                    ha="center", va="center",
                    color="white" if cm[i][j] > thresh else "black",
                    fontweight='bold', fontsize=12)
            
    fig.tight_layout()
    save_path = save_dir / f"confusion_matrix_{model_key}.png"
    plt.savefig(save_path, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"📊 Confusion matrix saved to {save_path.name}")

def plot_comparison_chart(metrics_data, save_dir=None):
    """Generates comparison bar chart of accuracy, precision, recall, and F1 across models."""
    save_dir = save_dir or PATHS["reports_dir"]
    save_dir.mkdir(parents=True, exist_ok=True)
    
    models = list(metrics_data.keys())
    accuracies = [metrics_data[m]["accuracy"] * 100 for m in models]
    precisions = [metrics_data[m]["precision"] * 100 for m in models]
    recalls = [metrics_data[m]["recall"] * 100 for m in models]
    f1s = [metrics_data[m]["f1_score"] * 100 for m in models]
    
    x = np.arange(len(models))
    width = 0.2
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Custom dark slate color palette matching the UI
    ax.bar(x - 1.5*width, accuracies, width, label='Accuracy', color='#00f2fe')
    ax.bar(x - 0.5*width, precisions, width, label='Precision', color='#4facfe')
    ax.bar(x + 0.5*width, recalls, width, label='Recall', color='#0070f3')
    ax.bar(x + 1.5*width, f1s, width, label='F1-Score', color='#00e676')
    
    ax.set_ylabel('Percentage (%)', fontsize=11, fontweight='bold')
    ax.set_title('NLP Fake News Classifier Model Benchmarks', fontsize=13, fontweight='bold', pad=15)
    ax.set_xticks(x)
    ax.set_xticklabels([MODELS[m]["name"] for m in models], fontsize=10, fontweight='medium')
    ax.set_ylim(0, 110)
    ax.legend(loc='lower left', framealpha=0.9)
    ax.grid(axis='y', linestyle='--', alpha=0.3)
    
    # Set background styling to fit dark/light theme report integration
    ax.set_facecolor('#f7f9fc')
    fig.patch.set_facecolor('#ffffff')
    
    fig.tight_layout()
    save_path = save_dir / "model_comparison_chart.png"
    plt.savefig(save_path, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"📊 Model comparison chart saved to {save_path.name}")

if __name__ == "__main__":
    # Test generation
    report_file = PATHS["reports_dir"] / "all_models_metrics.json"
    if report_file.exists():
        with open(report_file) as f:
            data = json.load(f)
        plot_comparison_chart(data)
        for key in ["pac", "nb", "lr", "ensemble"]:
            if key in data:
                plot_confusion_matrix(data[key]["confusion_matrix"], key)
