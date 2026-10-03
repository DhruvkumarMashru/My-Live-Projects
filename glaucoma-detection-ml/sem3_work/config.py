"""
======================================================================
  Advanced Retinal OCT-Based Early Glaucoma Detection System
  System Configuration
======================================================================
  Author  : Clinical Diagnostics Team
  Year    : 2026
======================================================================
"""

import os
import sys
from pathlib import Path

# Reconfigure stdout/stderr to UTF-8 to handle emojis on Windows
if sys.platform.startswith('win'):
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8')

# ── Project Root ────────────────────────────────────────────────────
ROOT_DIR = Path(__file__).parent.resolve()

# ── Dataset Configuration ────────────────────────────────────────────
DATASET = {
    "kaggle_dataset": "sshikamaru/glaucoma-detection",
    "raw_dir":        ROOT_DIR / "data" / "raw",
    "processed_dir":  ROOT_DIR / "data" / "processed",
    "train_dir":      ROOT_DIR / "data" / "processed" / "train",
    "val_dir":        ROOT_DIR / "data" / "processed" / "val",
    "test_dir":       ROOT_DIR / "data" / "processed" / "test",
    "classes":        ["normal", "glaucoma"],
    "class_to_idx":   {"normal": 0, "glaucoma": 1},
}

# ── Image Configuration ─────────────────────────────────────────────
IMAGE = {
    "size":           224,          # Input image size (224×224)
    "channels":       3,
    "mean":           [0.485, 0.456, 0.406],   # ImageNet mean
    "std":            [0.229, 0.224, 0.225],   # ImageNet std
}

# ── Training Configuration (Optimised for 2GB VRAM) ─────────────────
TRAIN = {
    "batch_size":          16,       # Optimized batch for faster training
    "num_epochs":          50,
    "learning_rate":       1e-4,
    "weight_decay":        1e-4,
    "patience":            10,       # Early stopping patience
    "lr_step_size":        10,
    "lr_gamma":            0.5,
    "num_workers":         2,
    "pin_memory":          True,
    "mixed_precision":     True,     # AMP for 2GB GPU optimisation
    "gradient_accumulation_steps": 2,  # Effective batch = 32
    "train_split":         0.70,
    "val_split":           0.15,
    "test_split":          0.15,
    "seed":                42,
}

# ── Model Configuration ──────────────────────────────────────────────
MODELS = {
    "cnn": {
        "name":          "Custom CNN",
        "dropout":       0.5,
        "file":          "model_cnn.pth",
    },
    "vgg16": {
        "name":          "VGG16",
        "pretrained":    True,
        "freeze_layers": 10,
        "file":          "model_vgg16.pth",
    },
}

# ── Paths ────────────────────────────────────────────────────────────
PATHS = {
    "models_dir":    ROOT_DIR / "models",
    "reports_dir":   ROOT_DIR / "reports",
    "logs_dir":      ROOT_DIR / "logs",
}

# ── Device Configuration ─────────────────────────────────────────────
import torch
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
GPU_INFO = {
    "available":     torch.cuda.is_available(),
    "device_name":   torch.cuda.get_device_name(0) if torch.cuda.is_available() else "CPU",
    "vram_gb":       round(torch.cuda.get_device_properties(0).total_memory / 1e9, 2)
                     if torch.cuda.is_available() else 0,
}

# ── Create All Directories ───────────────────────────────────────────
def create_directories():
    dirs = [
        DATASET["raw_dir"], DATASET["processed_dir"],
        DATASET["train_dir"] / "normal",
        DATASET["train_dir"] / "glaucoma",
        DATASET["val_dir"] / "normal",
        DATASET["val_dir"] / "glaucoma",
        DATASET["test_dir"] / "normal",
        DATASET["test_dir"] / "glaucoma",
        PATHS["models_dir"],
        PATHS["reports_dir"],
        PATHS["logs_dir"],
    ]
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)
    print("✅ All directories created successfully.")

if __name__ == "__main__":
    create_directories()
    print(f"\n📋 Project Configuration:")
    print(f"   Device        : {DEVICE}")
    print(f"   GPU Available : {GPU_INFO['available']}")
    if GPU_INFO["available"]:
        print(f"   GPU Name      : {GPU_INFO['device_name']}")
        print(f"   VRAM          : {GPU_INFO['vram_gb']} GB")
    print(f"   Batch Size    : {TRAIN['batch_size']}")
    print(f"   Image Size    : {IMAGE['size']}×{IMAGE['size']}")
    print(f"   Mixed Prec.   : {TRAIN['mixed_precision']}")
