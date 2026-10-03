"""
======================================================================
  Model 1 — Custom CNN Baseline
======================================================================
  A purpose-built CNN architecture for retinal OCT glaucoma detection.
  Uses residual-style skip connections for better gradient flow.
  Designed to run efficiently on 2GB VRAM.
======================================================================
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import IMAGE, MODELS, PATHS


class ConvBlock(nn.Module):
    """Convolutional block: Conv → BN → ReLU → (optional) Dropout"""
    def __init__(self, in_ch, out_ch, kernel=3, stride=1, padding=1, dropout=0.0):
        super().__init__()
        self.block = nn.Sequential(
            nn.Conv2d(in_ch, out_ch, kernel, stride, padding, bias=False),
            nn.BatchNorm2d(out_ch),
            nn.ReLU(inplace=True),
            nn.Dropout2d(dropout) if dropout > 0 else nn.Identity(),
        )
    
    def forward(self, x):
        return self.block(x)


class ResidualBlock(nn.Module):
    """Lightweight residual block for better gradient flow."""
    def __init__(self, channels):
        super().__init__()
        self.conv1 = ConvBlock(channels, channels)
        self.conv2 = nn.Sequential(
            nn.Conv2d(channels, channels, 3, 1, 1, bias=False),
            nn.BatchNorm2d(channels),
        )
        self.relu = nn.ReLU(inplace=True)
    
    def forward(self, x):
        return self.relu(self.conv2(self.conv1(x)) + x)


class GlaucomaCNN(nn.Module):
    """
    Custom CNN for Glaucoma Detection from Retinal OCT images.
    
    Architecture:
      Input (3, 224, 224)
      → Block1 (32 ch) → MaxPool → Block2 (64 ch) → MaxPool
      → Block3 (128 ch) → ResBlock → MaxPool → Block4 (256 ch)
      → GlobalAvgPool → FC(512) → Dropout → FC(2)
    
    Parameters: ~4.2M — fast on CPU & 2GB GPU
    """
    
    def __init__(self, num_classes: int = 2, dropout: float = 0.5):
        super().__init__()
        
        # ── Feature Extractor ────────────────────────────────────────
        self.features = nn.Sequential(
            # Block 1: 224 → 112
            ConvBlock(3, 32, dropout=0.1),
            ConvBlock(32, 32),
            nn.MaxPool2d(2, 2),
            
            # Block 2: 112 → 56
            ConvBlock(32, 64, dropout=0.1),
            ConvBlock(64, 64),
            nn.MaxPool2d(2, 2),
            
            # Block 3: 56 → 28
            ConvBlock(64, 128, dropout=0.2),
            ConvBlock(128, 128),
            ResidualBlock(128),
            nn.MaxPool2d(2, 2),
            
            # Block 4: 28 → 14
            ConvBlock(128, 256, dropout=0.2),
            ConvBlock(256, 256),
            ResidualBlock(256),
            nn.MaxPool2d(2, 2),
            
            # Block 5: 14 → 7
            ConvBlock(256, 512, dropout=0.3),
            ConvBlock(512, 512),
            nn.MaxPool2d(2, 2),
        )
        
        # ── Global Average Pooling ───────────────────────────────────
        self.gap = nn.AdaptiveAvgPool2d(1)
        
        # ── Classifier ───────────────────────────────────────────────
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(512, 256),
            nn.ReLU(inplace=True),
            nn.Dropout(dropout),
            nn.Linear(256, 128),
            nn.ReLU(inplace=True),
            nn.Dropout(dropout * 0.5),
            nn.Linear(128, num_classes),
        )
        
        # ── Weight Initialisation ────────────────────────────────────
        self._init_weights()
    
    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.ones_(m.weight)
                nn.init.zeros_(m.bias)
            elif isinstance(m, nn.Linear):
                nn.init.xavier_normal_(m.weight)
                nn.init.zeros_(m.bias)
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = self.features(x)
        x = self.gap(x)
        x = self.classifier(x)
        return x
    
    def get_feature_maps(self, x: torch.Tensor) -> torch.Tensor:
        """Returns last conv feature maps for Grad-CAM."""
        return self.features(x)


def build_cnn_model(num_classes: int = 2) -> GlaucomaCNN:
    """Build and return the CNN model."""
    cfg = MODELS["cnn"]
    model = GlaucomaCNN(num_classes=num_classes, dropout=cfg["dropout"])
    total_params = sum(p.numel() for p in model.parameters())
    trainable    = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"  Custom CNN    | Params: {total_params/1e6:.2f}M | Trainable: {trainable/1e6:.2f}M")
    return model


if __name__ == "__main__":
    model = build_cnn_model()
    x = torch.randn(2, 3, 224, 224)
    out = model(x)
    print(f"Output shape: {out.shape}")  # Expected: [2, 2]
