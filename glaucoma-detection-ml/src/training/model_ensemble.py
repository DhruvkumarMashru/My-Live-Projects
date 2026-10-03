"""
======================================================================
  Model 5 — Ensemble Model
======================================================================
  Combines predictions from ResNet50 + EfficientNetB0 + VGG16
  using weighted averaging for maximum accuracy.
======================================================================
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import MODELS, PATHS, DEVICE


class EnsembleModel(nn.Module):
    """
    Weighted ensemble of multiple trained models.
    Uses soft probability averaging for final prediction.
    
    Ensemble strategy:
      P_final = w1*P_resnet + w2*P_efficientnet + w3*P_vgg
    
    Weights tuned based on individual model validation accuracy.
    """
    
    def __init__(self, models: list, weights: list = None):
        """
        Args:
            models:  List of trained PyTorch models
            weights: Ensemble weights (must sum to 1.0)
        """
        super().__init__()
        
        self.models  = nn.ModuleList(models)
        cfg          = MODELS["ensemble"]
        self.weights = weights or cfg["weights"]
        
        assert len(self.models) == len(self.weights), \
            "Number of models must match number of weights"
        assert abs(sum(self.weights) - 1.0) < 1e-5, \
            "Weights must sum to 1.0"
        
        # Freeze all sub-models (they are already trained)
        for model in self.models:
            for param in model.parameters():
                param.requires_grad = False
        
        # Optional learnable blending layer
        self.use_learnable = False
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """Weighted average of softmax probabilities from all models."""
        probs_list = []
        
        for model in self.models:
            model.eval()
            with torch.no_grad():
                logits = model(x)
                probs  = F.softmax(logits, dim=1)
                probs_list.append(probs)
        
        # Weighted average
        ensemble_probs = torch.zeros_like(probs_list[0])
        for w, p in zip(self.weights, probs_list):
            ensemble_probs += w * p
        
        # Return log-probs for compatibility with NLLLoss or raw logits
        return torch.log(ensemble_probs + 1e-10)
    
    def predict(self, x: torch.Tensor):
        """
        Returns:
            predictions: Predicted class indices
            confidence:  Confidence scores (max probability)
            all_probs:   Per-class probabilities
        """
        log_probs  = self.forward(x)
        probs      = torch.exp(log_probs)
        confidence, predictions = torch.max(probs, dim=1)
        return predictions, confidence, probs


def load_ensemble(model_paths: dict, device: torch.device = None):
    """
    Load trained models from disk and create ensemble.
    
    Args:
        model_paths: Dict of {model_name: path_to_checkpoint}
        device: torch device
    
    Returns:
        EnsembleModel
    """
    from src.training.model_cnn      import build_cnn_model
    from src.training.model_transfer import build_resnet50_model, \
                                            build_efficientnet_model, \
                                            build_vgg16_model
    
    device = device or DEVICE
    builders = {
        "cnn":          build_cnn_model,
        "vgg16":        build_vgg16_model,
        "resnet50":     build_resnet50_model,
        "efficientnet": build_efficientnet_model,
    }
    
    loaded_models = []
    for name, path in model_paths.items():
        path = Path(path)
        if not path.exists():
            print(f"⚠️  Checkpoint not found: {path}. Skipping {name}.")
            continue
        
        model = builders[name]()
        state = torch.load(path, map_location=device)
        
        # Handle state dict key differences
        if "model_state_dict" in state:
            model.load_state_dict(state["model_state_dict"])
        else:
            model.load_state_dict(state)
        
        model = model.to(device)
        model.eval()
        loaded_models.append(model)
        print(f"  ✅ Loaded {name} from {path.name}")
    
    if len(loaded_models) < 2:
        raise RuntimeError("Need at least 2 models for ensemble!")
    
    # Adjust weights to match loaded models
    weights = MODELS["ensemble"]["weights"][:len(loaded_models)]
    total   = sum(weights)
    weights = [w / total for w in weights]  # Re-normalise
    
    ensemble = EnsembleModel(loaded_models, weights)
    print(f"\n✅ Ensemble created with {len(loaded_models)} models")
    print(f"   Weights: {[f'{w:.2f}' for w in weights]}")
    return ensemble
