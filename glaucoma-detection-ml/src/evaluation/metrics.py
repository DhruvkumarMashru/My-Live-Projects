"""
======================================================================
  Evaluation & Performance Metrics — All 5 Models
======================================================================
  Computes: Accuracy, Precision, Recall, F1, AUC-ROC, Sensitivity,
            Specificity, Confusion Matrix, Classification Report
  Generates: Comparison charts, ROC curves, confusion matrices
======================================================================
"""

import sys
import json
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import seaborn as sns
from pathlib import Path
from typing import Dict, List

from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, roc_curve, confusion_matrix, classification_report,
    matthews_corrcoef
)

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import PATHS, DATASET

# Seaborn style
sns.set_style("whitegrid")
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 12})


# ── Core Metrics Computation ─────────────────────────────────────────
def compute_metrics(y_true: np.ndarray, y_pred: np.ndarray,
                    y_prob: np.ndarray = None) -> Dict:
    """
    Compute comprehensive evaluation metrics.
    
    Args:
        y_true: Ground truth labels
        y_pred: Predicted labels
        y_prob: Predicted probabilities (for AUC-ROC)
    
    Returns:
        Dictionary of all computed metrics
    """
    cm = confusion_matrix(y_true, y_pred)
    
    # Extract TP, TN, FP, FN for binary classification
    if cm.shape == (2, 2):
        tn, fp, fn, tp = cm.ravel()
        sensitivity    = tp / (tp + fn + 1e-8)  # Recall for positive class
        specificity    = tn / (tn + fp + 1e-8)
    else:
        sensitivity = specificity = None
    
    metrics = {
        "accuracy":    accuracy_score(y_true, y_pred),
        "precision":   precision_score(y_true, y_pred, average="weighted", zero_division=0),
        "recall":      recall_score(y_true, y_pred,    average="weighted", zero_division=0),
        "f1_score":    f1_score(y_true, y_pred,        average="weighted", zero_division=0),
        "mcc":         matthews_corrcoef(y_true, y_pred),
        "sensitivity": sensitivity,
        "specificity": specificity,
        "confusion_matrix": cm.tolist(),
    }
    
    if y_prob is not None:
        try:
            # Binary classification: probability of positive class
            prob_positive = y_prob[:, 1] if y_prob.ndim > 1 else y_prob
            metrics["auc_roc"]   = roc_auc_score(y_true, prob_positive)
            metrics["roc_curve"] = roc_curve(y_true, prob_positive)
        except Exception:
            metrics["auc_roc"]   = None
    
    return metrics


# ── Confusion Matrix Plot ────────────────────────────────────────────
def plot_confusion_matrix(cm: np.ndarray, model_name: str,
                          class_names: List[str] = None, save: bool = True):
    class_names = class_names or DATASET["classes"]
    
    fig, ax = plt.subplots(figsize=(7, 6))
    sns.heatmap(
        cm, annot=True, fmt="d", cmap="Blues",
        xticklabels=class_names, yticklabels=class_names,
        linewidths=1, linecolor="white",
        cbar_kws={"shrink": 0.8}, ax=ax,
        annot_kws={"size": 16, "weight": "bold"},
    )
    ax.set_title(f"Confusion Matrix — {model_name.upper()}", fontsize=14, pad=15)
    ax.set_ylabel("True Label",      fontsize=12)
    ax.set_xlabel("Predicted Label", fontsize=12)
    
    # Add percentage annotations
    total = cm.sum()
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            pct = cm[i, j] / total * 100
            ax.text(j + 0.5, i + 0.7, f"({pct:.1f}%)",
                    ha="center", va="center", fontsize=10, color="gray")
    
    plt.tight_layout()
    if save:
        path = PATHS["reports_dir"] / f"confusion_matrix_{model_name}.png"
        plt.savefig(path, dpi=150, bbox_inches="tight")
        print(f"  💾 Confusion matrix → {path.name}")
    plt.close()


# ── ROC Curve Plot ───────────────────────────────────────────────────
def plot_roc_curves(all_metrics: Dict, save: bool = True):
    fig, ax = plt.subplots(figsize=(9, 7))
    
    colors = ["#2196F3", "#4CAF50", "#FF5722", "#9C27B0", "#FF9800"]
    
    for i, (model_name, metrics) in enumerate(all_metrics.items()):
        if "roc_curve" not in metrics or metrics["roc_curve"] is None:
            continue
        fpr, tpr, _ = metrics["roc_curve"]
        auc = metrics.get("auc_roc", 0)
        label = f"{MODELS_DISPLAY.get(model_name, model_name.upper())} (AUC = {auc:.4f})"
        ax.plot(fpr, tpr, color=colors[i % len(colors)],
                linewidth=2.5, label=label)
    
    ax.plot([0, 1], [0, 1], "k--", linewidth=1.5, alpha=0.5, label="Random Classifier")
    ax.fill_between([0, 1], [0, 1], alpha=0.05, color="gray")
    
    ax.set_title("ROC Curves — All Models Comparison", fontsize=14, fontweight="bold")
    ax.set_xlabel("False Positive Rate (1 - Specificity)", fontsize=12)
    ax.set_ylabel("True Positive Rate (Sensitivity)",       fontsize=12)
    ax.legend(loc="lower right", fontsize=10)
    ax.grid(alpha=0.3)
    ax.set_xlim([0, 1])
    ax.set_ylim([0, 1.01])
    
    plt.tight_layout()
    if save:
        path = PATHS["reports_dir"] / "roc_curves_all_models.png"
        plt.savefig(path, dpi=150, bbox_inches="tight")
        print(f"  💾 ROC curves → {path.name}")
    plt.close()


MODELS_DISPLAY = {
    "cnn":          "Custom CNN",
    "vgg16":        "VGG16",
    "resnet50":     "ResNet50",
    "efficientnet": "EfficientNetB0",
    "ensemble":     "Ensemble",
}


# ── Model Comparison Chart ───────────────────────────────────────────
def plot_comparison_chart(all_metrics: Dict, save: bool = True):
    """Create a comprehensive bar chart comparing all models."""
    
    metric_names = ["accuracy", "precision", "recall", "f1_score", "auc_roc"]
    metric_labels = ["Accuracy", "Precision", "Recall", "F1-Score", "AUC-ROC"]
    
    model_names = list(all_metrics.keys())
    display_names = [MODELS_DISPLAY.get(m, m.upper()) for m in model_names]
    
    data = {}
    for m_name in metric_names:
        data[m_name] = []
        for model in model_names:
            val = all_metrics[model].get(m_name)
            data[m_name].append(val if val is not None else 0)
    
    x    = np.arange(len(model_names))
    n    = len(metric_names)
    w    = 0.15
    colors = ["#2196F3", "#4CAF50", "#FF5722", "#9C27B0", "#FF9800"]
    
    fig, ax = plt.subplots(figsize=(14, 7))
    
    for i, (metric, label, color) in enumerate(zip(metric_names, metric_labels, colors)):
        vals   = data[metric]
        offset = (i - n / 2) * w + w / 2
        bars   = ax.bar(x + offset, vals, width=w, label=label, color=color, alpha=0.85, edgecolor="white")
        
        # Add value labels
        for bar, val in zip(bars, vals):
            if val > 0:
                ax.text(bar.get_x() + bar.get_width() / 2,
                        bar.get_height() + 0.005,
                        f"{val:.3f}",
                        ha="center", va="bottom", fontsize=7.5, rotation=45)
    
    ax.set_xticks(x)
    ax.set_xticklabels(display_names, fontsize=11)
    ax.set_ylim([0, 1.15])
    ax.set_ylabel("Score", fontsize=12)
    ax.set_title("Performance Comparison — All Deep Learning Models",
                 fontsize=14, fontweight="bold", pad=15)
    ax.legend(loc="upper right", fontsize=10)
    ax.grid(axis="y", alpha=0.3)
    ax.axhline(y=0.9, color="red", linestyle="--", alpha=0.5, linewidth=1, label="90% threshold")
    
    plt.tight_layout()
    if save:
        path = PATHS["reports_dir"] / "model_comparison_chart.png"
        plt.savefig(path, dpi=150, bbox_inches="tight")
        print(f"  💾 Comparison chart → {path.name}")
    plt.close()


# ── Sensitivity / Specificity Chart ─────────────────────────────────
def plot_sensitivity_specificity(all_metrics: Dict, save: bool = True):
    model_names   = list(all_metrics.keys())
    display_names = [MODELS_DISPLAY.get(m, m.upper()) for m in model_names]
    sensitivities = [all_metrics[m].get("sensitivity") or 0 for m in model_names]
    specificities = [all_metrics[m].get("specificity") or 0 for m in model_names]
    
    x = np.arange(len(model_names))
    w = 0.35
    
    fig, ax = plt.subplots(figsize=(11, 6))
    bars1 = ax.bar(x - w/2, sensitivities, w, label="Sensitivity (TPR)",
                   color="#E91E63", alpha=0.85, edgecolor="white")
    bars2 = ax.bar(x + w/2, specificities, w, label="Specificity (TNR)",
                   color="#00BCD4", alpha=0.85, edgecolor="white")
    
    for bars in [bars1, bars2]:
        for bar in bars:
            ax.text(bar.get_x() + bar.get_width()/2,
                    bar.get_height() + 0.008,
                    f"{bar.get_height():.3f}",
                    ha="center", va="bottom", fontsize=10)
    
    ax.set_xticks(x)
    ax.set_xticklabels(display_names, fontsize=11)
    ax.set_ylim([0, 1.12])
    ax.set_ylabel("Score", fontsize=12)
    ax.set_title("Sensitivity vs Specificity — Clinical Performance",
                 fontsize=13, fontweight="bold")
    ax.legend(fontsize=11)
    ax.grid(axis="y", alpha=0.3)
    
    plt.tight_layout()
    if save:
        path = PATHS["reports_dir"] / "sensitivity_specificity.png"
        plt.savefig(path, dpi=150, bbox_inches="tight")
        print(f"  💾 Sensitivity/Specificity → {path.name}")
    plt.close()


# ── Summary Table ────────────────────────────────────────────────────
def print_comparison_table(all_metrics: Dict):
    """Print a formatted metrics comparison table."""
    header = f"\n{'='*85}"
    cols   = f"  {'Model':<20} {'Accuracy':>9} {'Precision':>10} {'Recall':>8} {'F1':>8} {'AUC':>8} {'Sens.':>7} {'Spec.':>7}"
    
    print(header)
    print("  📊 MODEL PERFORMANCE COMPARISON TABLE")
    print(header)
    print(cols)
    print("-"*85)
    
    for model_name, metrics in all_metrics.items():
        name = MODELS_DISPLAY.get(model_name, model_name.upper())
        acc  = f"{metrics.get('accuracy',    0)*100:.2f}%"
        prec = f"{metrics.get('precision',   0)*100:.2f}%"
        rec  = f"{metrics.get('recall',      0)*100:.2f}%"
        f1   = f"{metrics.get('f1_score',    0)*100:.2f}%"
        auc  = f"{metrics.get('auc_roc',     0)*100:.2f}%" if metrics.get("auc_roc") else "  N/A  "
        sens = f"{metrics.get('sensitivity', 0)*100:.2f}%" if metrics.get("sensitivity") else "  N/A  "
        spec = f"{metrics.get('specificity', 0)*100:.2f}%" if metrics.get("specificity") else "  N/A  "
        print(f"  {name:<20} {acc:>9} {prec:>10} {rec:>8} {f1:>8} {auc:>8} {sens:>7} {spec:>7}")
    
    print("="*85)
    
    # Best model
    best = max(all_metrics.items(), key=lambda x: x[1].get("accuracy", 0))
    print(f"\n  🏆 Best Model: {MODELS_DISPLAY.get(best[0], best[0].upper())} "
          f"(Accuracy: {best[1]['accuracy']*100:.2f}%)\n")


# ── Save Combined Report ─────────────────────────────────────────────
def save_metrics_report(all_metrics: Dict):
    """Save all metrics to a JSON file."""
    PATHS["reports_dir"].mkdir(parents=True, exist_ok=True)
    
    # Convert numpy / roc_curve tuples to JSON-serializable
    serializable = {}
    for model_name, metrics in all_metrics.items():
        m = {k: v for k, v in metrics.items() if k != "roc_curve"}
        for key in ["sensitivity", "specificity", "auc_roc", "mcc"]:
            if m.get(key) is not None:
                m[key] = float(m[key])
        serializable[model_name] = m
    
    out_path = PATHS["reports_dir"] / "all_models_metrics.json"
    with open(out_path, "w") as f:
        json.dump(serializable, f, indent=2)
    
    print(f"\n  💾 Metrics report → {out_path}")
