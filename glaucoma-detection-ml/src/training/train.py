"""
======================================================================
  Unified Training Script — All 5 Models
======================================================================
  Features:
  - Mixed Precision Training (AMP) for 2GB GPU
  - Gradient Accumulation (effective batch = 32)
  - Learning Rate Scheduler (ReduceLROnPlateau)
  - Early Stopping
  - Checkpoint saving (best model)
  - Training curve logging
  - Class-weighted loss for imbalanced data
======================================================================

  Usage:
    python src/training/train.py --model cnn
    python src/training/train.py --model vgg16
    python src/training/train.py --model resnet50
    python src/training/train.py --model efficientnet
    python src/training/train.py --model all          # Train all 4

======================================================================
"""

import os
import sys

# Reconfigure stdout/stderr to UTF-8 to handle emojis on Windows
if sys.platform.startswith('win'):
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8')

import json
import time
import argparse
import warnings
warnings.filterwarnings("ignore")

from pathlib import Path
from datetime import datetime
from typing import Dict, Tuple, Optional

import torch
import torch.nn as nn
import torch.optim as optim
from torch.cuda.amp import GradScaler, autocast

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from tqdm import tqdm

# Project imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import TRAIN, PATHS, DEVICE, GPU_INFO, MODELS

from src.data.dataset_loader import get_dataloaders
from src.training.model_cnn  import build_cnn_model
from src.training.model_transfer import (
    build_vgg16_model, build_resnet50_model, build_efficientnet_model
)


# ── Logging ──────────────────────────────────────────────────────────
def log(msg: str, level: str = "INFO"):
    icons = {"INFO": "ℹ️ ", "SUCCESS": "✅", "WARNING": "⚠️ ", "ERROR": "❌"}
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {icons.get(level, '')} {msg}")


# ── Early Stopping ───────────────────────────────────────────────────
class EarlyStopping:
    def __init__(self, patience: int = 10, delta: float = 1e-4, mode: str = "max"):
        self.patience   = patience
        self.delta      = delta
        self.mode       = mode
        self.best_score = None
        self.counter    = 0
        self.stop       = False
    
    def __call__(self, score: float) -> bool:
        if self.best_score is None:
            self.best_score = score
            return False
        
        improved = (score > self.best_score + self.delta) if self.mode == "max" \
               else (score < self.best_score - self.delta)
        
        if improved:
            self.best_score = score
            self.counter    = 0
        else:
            self.counter += 1
            log(f"EarlyStopping: {self.counter}/{self.patience}", "WARNING")
            if self.counter >= self.patience:
                self.stop = True
        
        return self.stop


# ── Training Loop ────────────────────────────────────────────────────
def train_one_epoch(
    model:    nn.Module,
    loader,
    optimizer: optim.Optimizer,
    criterion: nn.Module,
    scaler:    GradScaler,
    device:    torch.device,
    accum_steps: int = 4,
) -> Tuple[float, float]:
    """
    Train model for one epoch with AMP + gradient accumulation.
    
    Returns:
        (avg_loss, avg_accuracy)
    """
    model.train()
    total_loss  = 0.0
    correct     = 0
    total       = 0
    
    optimizer.zero_grad()
    
    pbar = tqdm(loader, desc="  Training", leave=False, ncols=90)
    
    for step, (images, labels) in enumerate(pbar):
        images = images.to(device, non_blocking=True)
        labels = labels.to(device, non_blocking=True)
        
        # Mixed precision forward
        with autocast(enabled=TRAIN["mixed_precision"]):
            outputs = model(images)
            loss    = criterion(outputs, labels) / accum_steps
        
        # Scaled backward
        scaler.scale(loss).backward()
        
        # Gradient accumulation step
        if (step + 1) % accum_steps == 0 or (step + 1) == len(loader):
            scaler.unscale_(optimizer)
            nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            scaler.step(optimizer)
            scaler.update()
            optimizer.zero_grad()
        
        # Metrics
        total_loss += loss.item() * accum_steps
        preds       = outputs.argmax(dim=1)
        correct    += (preds == labels).sum().item()
        total      += labels.size(0)
        
        pbar.set_postfix(loss=f"{total_loss/(step+1):.4f}",
                         acc=f"{correct/total:.4f}")
    
    return total_loss / len(loader), correct / total


@torch.no_grad()
def evaluate(
    model:     nn.Module,
    loader,
    criterion: nn.Module,
    device:    torch.device,
) -> Tuple[float, float, np.ndarray, np.ndarray]:
    """
    Evaluate model on validation or test set.
    
    Returns:
        (avg_loss, accuracy, all_labels, all_preds)
    """
    model.eval()
    total_loss = 0.0
    all_preds  = []
    all_labels = []
    
    for images, labels in tqdm(loader, desc="  Evaluating", leave=False, ncols=90):
        images = images.to(device, non_blocking=True)
        labels = labels.to(device, non_blocking=True)
        
        with autocast(enabled=TRAIN["mixed_precision"]):
            outputs = model(images)
            loss    = criterion(outputs, labels)
        
        total_loss += loss.item()
        preds       = outputs.argmax(dim=1)
        all_preds.extend(preds.cpu().numpy())
        all_labels.extend(labels.cpu().numpy())
    
    all_preds  = np.array(all_preds)
    all_labels = np.array(all_labels)
    accuracy   = (all_preds == all_labels).mean()
    
    return total_loss / len(loader), accuracy, all_labels, all_preds


# ── Save Checkpoint ──────────────────────────────────────────────────
def save_checkpoint(model, optimizer, epoch, val_acc, model_name: str, is_best: bool = False):
    PATHS["models_dir"].mkdir(parents=True, exist_ok=True)
    
    checkpoint = {
        "epoch":            epoch,
        "model_state_dict": model.state_dict(),
        "optimizer_state":  optimizer.state_dict(),
        "val_accuracy":     val_acc,
        "model_name":       model_name,
        "timestamp":        datetime.now().isoformat(),
    }
    
    # Save last checkpoint
    last_path = PATHS["models_dir"] / f"model_{model_name}_last.pth"
    torch.save(checkpoint, last_path)
    
    # Save best checkpoint
    if is_best:
        best_path = PATHS["models_dir"] / MODELS.get(model_name, {}).get("file", f"model_{model_name}.pth")
        torch.save(checkpoint, best_path)
        log(f"💾 Best model saved → {best_path.name} (Val Acc: {val_acc:.4f})", "SUCCESS")


# ── Plot Training Curves ─────────────────────────────────────────────
def plot_curves(history: dict, model_name: str):
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle(f"Training Curves — {model_name.upper()}", fontsize=14, fontweight="bold")
    
    epochs = range(1, len(history["train_loss"]) + 1)
    
    # Loss
    axes[0].plot(epochs, history["train_loss"], "b-o", label="Train Loss", markersize=3)
    axes[0].plot(epochs, history["val_loss"],   "r-o", label="Val Loss",   markersize=3)
    axes[0].set_title("Loss")
    axes[0].set_xlabel("Epoch")
    axes[0].set_ylabel("Loss")
    axes[0].legend()
    axes[0].grid(alpha=0.3)
    
    # Accuracy
    axes[1].plot(epochs, history["train_acc"], "b-o", label="Train Acc", markersize=3)
    axes[1].plot(epochs, history["val_acc"],   "r-o", label="Val Acc",   markersize=3)
    axes[1].set_title("Accuracy")
    axes[1].set_xlabel("Epoch")
    axes[1].set_ylabel("Accuracy")
    axes[1].legend()
    axes[1].grid(alpha=0.3)
    axes[1].set_ylim([0, 1])
    
    plt.tight_layout()
    
    PATHS["reports_dir"].mkdir(parents=True, exist_ok=True)
    save_path = PATHS["reports_dir"] / f"training_curves_{model_name}.png"
    plt.savefig(save_path, dpi=150, bbox_inches="tight")
    plt.close()
    log(f"📊 Training curves saved → {save_path.name}", "SUCCESS")


# ── Main Trainer ─────────────────────────────────────────────────────
def train_model(
    model_name:    str,
    num_epochs:    Optional[int] = None,
    learning_rate: Optional[float] = None,
) -> Dict:
    """
    Full training pipeline for a single model.
    
    Args:
        model_name: 'cnn' | 'vgg16' | 'resnet50' | 'efficientnet'
        num_epochs: Override config epochs
        learning_rate: Override config LR
    
    Returns:
        results dict with final metrics
    """
    print("\n" + "="*65)
    print(f"  🚀 Training: {MODELS.get(model_name, {}).get('name', model_name.upper())}")
    print(f"  Device     : {DEVICE}")
    if GPU_INFO["available"]:
        print(f"  GPU        : {GPU_INFO['device_name']} ({GPU_INFO['vram_gb']} GB)")
    print("="*65)
    
    # ── Setup ──────────────────────────────────────────────────────
    torch.manual_seed(TRAIN["seed"])
    if DEVICE.type == "cuda":
        torch.cuda.manual_seed(TRAIN["seed"])
    
    epochs = num_epochs or TRAIN["num_epochs"]
    lr     = learning_rate or TRAIN["learning_rate"]
    
    # ── DataLoaders ────────────────────────────────────────────────
    train_loader, val_loader, test_loader = get_dataloaders()
    
    # ── Model ──────────────────────────────────────────────────────
    model_builders = {
        "cnn":          build_cnn_model,
        "vgg16":        build_vgg16_model,
        "resnet50":     build_resnet50_model,
        "efficientnet": build_efficientnet_model,
    }
    
    if model_name not in model_builders:
        raise ValueError(f"Unknown model: {model_name}")
    
    model = model_builders[model_name]().to(DEVICE)
    
    # ── Loss with class weights ────────────────────────────────────
    from src.data.dataset_loader import GlaucomaDataset, get_transforms
    temp_ds = GlaucomaDataset(
        root_dir=PATHS.get("train_dir", Path("data/processed/train")),
        transform=get_transforms("train"),
    )
    class_weights = temp_ds.get_class_weights().to(DEVICE)
    criterion = nn.CrossEntropyLoss(weight=class_weights)
    
    # ── Optimizer ─────────────────────────────────────────────────
    optimizer = optim.AdamW(
        filter(lambda p: p.requires_grad, model.parameters()),
        lr=lr,
        weight_decay=TRAIN["weight_decay"],
    )
    
    # ── Schedulers ────────────────────────────────────────────────
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, mode="max", factor=0.5, patience=5
    )
    
    # ── AMP Scaler ────────────────────────────────────────────────
    scaler = GradScaler(enabled=TRAIN["mixed_precision"] and DEVICE.type == "cuda")
    
    # ── Early Stopping ────────────────────────────────────────────
    early_stop = EarlyStopping(patience=TRAIN["patience"], mode="max")
    
    # ── History ───────────────────────────────────────────────────
    history = {
        "train_loss": [], "val_loss": [],
        "train_acc":  [], "val_acc":  [],
    }
    best_val_acc   = 0.0
    start_time     = time.time()
    
    # ── Training Loop ─────────────────────────────────────────────
    log("Starting training...")
    for epoch in range(1, epochs + 1):
        current_lr = optimizer.param_groups[0]["lr"]
        print(f"\n  Epoch {epoch:3d}/{epochs} | LR: {current_lr:.2e}")
        
        # Train
        train_loss, train_acc = train_one_epoch(
            model, train_loader, optimizer, criterion, scaler, DEVICE,
            accum_steps=TRAIN["gradient_accumulation_steps"]
        )
        
        # Validate
        val_loss, val_acc, val_labels, val_preds = evaluate(
            model, val_loader, criterion, DEVICE
        )
        
        # Log metrics
        history["train_loss"].append(train_loss)
        history["val_loss"].append(val_loss)
        history["train_acc"].append(train_acc)
        history["val_acc"].append(val_acc)
        
        print(f"  Train: loss={train_loss:.4f} acc={train_acc:.4f} | "
              f"Val: loss={val_loss:.4f} acc={val_acc:.4f}")
        
        # Scheduler step
        scheduler.step(val_acc)
        
        # Save best model
        is_best = val_acc > best_val_acc
        if is_best:
            best_val_acc = val_acc
        save_checkpoint(model, optimizer, epoch, val_acc, model_name, is_best)
        
        # Early stopping
        if early_stop(val_acc):
            log(f"Early stopping at epoch {epoch}", "WARNING")
            break
    
    # ── Final Test Evaluation ──────────────────────────────────────
    log("Running final test evaluation...")
    
    # Load best model
    best_path = PATHS["models_dir"] / MODELS.get(model_name, {}).get("file", f"model_{model_name}.pth")
    if best_path.exists():
        checkpoint = torch.load(best_path, map_location=DEVICE)
        model.load_state_dict(checkpoint["model_state_dict"])
    
    test_loss, test_acc, test_labels, test_preds = evaluate(
        model, test_loader, criterion, DEVICE
    )
    
    elapsed = time.time() - start_time
    
    results = {
        "model_name":   model_name,
        "best_val_acc": best_val_acc,
        "test_acc":     test_acc,
        "test_loss":    test_loss,
        "train_time_s": elapsed,
        "epochs_run":   epoch,
        "history":      history,
        "test_labels":  test_labels.tolist(),
        "test_preds":   test_preds.tolist(),
    }
    
    # Save results JSON
    PATHS["reports_dir"].mkdir(parents=True, exist_ok=True)
    results_path = PATHS["reports_dir"] / f"results_{model_name}.json"
    with open(results_path, "w") as f:
        json.dump({k: v for k, v in results.items() if k != "history"
                   and not isinstance(v, list) or k in ["test_labels", "test_preds"]}, f, indent=2)
    
    # Plot curves
    plot_curves(history, model_name)
    
    print("\n" + "="*65)
    log(f"✅ {model_name.upper()} Training Complete!", "SUCCESS")
    log(f"   Best Val Acc : {best_val_acc:.4f} ({best_val_acc*100:.2f}%)")
    log(f"   Test Acc     : {test_acc:.4f} ({test_acc*100:.2f}%)")
    log(f"   Time Elapsed : {elapsed/60:.1f} minutes")
    print("="*65)
    
    return results


# ── CLI ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train Glaucoma Detection Models")
    parser.add_argument(
        "--model", type=str, default="all",
        choices=["cnn", "vgg16", "resnet50", "efficientnet", "all"],
        help="Which model to train"
    )
    parser.add_argument("--epochs",  type=int,   default=None)
    parser.add_argument("--lr",      type=float, default=None)
    args = parser.parse_args()
    
    models_to_train = (
        ["cnn", "vgg16", "resnet50", "efficientnet"]
        if args.model == "all" else [args.model]
    )
    
    all_results = {}
    for model_name in models_to_train:
        results = train_model(model_name, args.epochs, args.lr)
        all_results[model_name] = {
            "val_acc":  results["best_val_acc"],
            "test_acc": results["test_acc"],
        }
    
    print("\n" + "="*65)
    print("  📊 FINAL SUMMARY")
    print("="*65)
    print(f"  {'Model':<20} {'Val Acc':>10} {'Test Acc':>10}")
    print("-"*65)
    for name, r in all_results.items():
        print(f"  {name:<20} {r['val_acc']*100:>9.2f}% {r['test_acc']*100:>9.2f}%")
    print("="*65)
