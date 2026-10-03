"""
======================================================================
  Grad-CAM Explainability — Visual Heatmap Generation
======================================================================
  Generates Grad-CAM heatmaps showing WHICH regions of the retinal
  OCT image influenced the model's glaucoma detection decision.
  
  Critical for PhD research: explains model decision-making
  (optic disc, optic cup regions highlighted)
======================================================================
"""

import sys
import cv2
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from pathlib import Path
from PIL import Image
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.cm as cm

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import IMAGE, PATHS, DEVICE, DATASET


class GradCAM:
    """
    Gradient-weighted Class Activation Mapping (Grad-CAM).
    
    Reference: Selvaraju et al., "Grad-CAM: Visual Explanations from
    Deep Networks via Gradient-based Localization", ICCV 2017.
    
    Works with any CNN that has a named convolutional layer.
    """
    
    def __init__(self, model: nn.Module, target_layer: nn.Module):
        """
        Args:
            model:        Trained PyTorch model
            target_layer: The convolutional layer to hook (usually last conv layer)
        """
        self.model        = model
        self.target_layer = target_layer
        self.gradients    = None
        self.activations  = None
        
        self._register_hooks()
    
    def _register_hooks(self):
        """Register forward and backward hooks on the target layer."""
        def forward_hook(module, input, output):
            self.activations = output.detach()
        
        def backward_hook(module, grad_input, grad_output):
            self.gradients = grad_output[0].detach()
        
        self.target_layer.register_forward_hook(forward_hook)
        self.target_layer.register_backward_hook(backward_hook)
    
    def generate(self, input_tensor: torch.Tensor, target_class: int = None) -> np.ndarray:
        """
        Generate Grad-CAM heatmap for the input image.
        
        Args:
            input_tensor: Image tensor of shape (1, C, H, W)
            target_class: Class index to explain (None = predicted class)
        
        Returns:
            heatmap: numpy array of shape (H, W), values in [0, 1]
        """
        self.model.eval()
        
        # Forward pass
        output = self.model(input_tensor)
        
        # Use predicted class if target not specified
        if target_class is None:
            target_class = output.argmax(dim=1).item()
        
        # Zero gradients
        self.model.zero_grad()
        
        # Backward pass for target class
        class_score = output[0, target_class]
        class_score.backward()
        
        # Pool gradients over spatial dimensions (global average pooling)
        pooled_grads = self.gradients.mean(dim=[0, 2, 3])  # (C,)
        
        # Weight activations by pooled gradients
        activations = self.activations[0]  # (C, H, W)
        for i, weight in enumerate(pooled_grads):
            activations[i] *= weight
        
        # Aggregate channels and apply ReLU
        heatmap = activations.mean(dim=0).cpu().numpy()  # (H, W)
        heatmap = np.maximum(heatmap, 0)  # ReLU
        
        # Normalise to [0, 1]
        if heatmap.max() > 0:
            heatmap /= heatmap.max()
        
        return heatmap, target_class, output.softmax(dim=1).detach().cpu().numpy()[0]


def get_target_layer(model: nn.Module, model_name: str) -> nn.Module:
    """Return the appropriate target convolutional layer for each model."""
    
    if model_name == "cnn":
        # Last conv block of custom CNN
        return list(model.features.children())[-3]
    
    elif model_name == "vgg16":
        return model.features[-3]  # Last conv layer before MaxPool
    
    elif model_name == "resnet50":
        return model.backbone[-1][-1].conv3  # Last bottleneck conv
    
    elif model_name == "efficientnet":
        return model.features[-1][0]  # Last MBConv block
    
    else:
        raise ValueError(f"Unknown model_name: {model_name}")


def apply_heatmap_to_image(
    original_img: np.ndarray,
    heatmap:      np.ndarray,
    alpha:        float = 0.5,
    colormap:     int   = cv2.COLORMAP_JET,
) -> np.ndarray:
    """
    Overlay the Grad-CAM heatmap on the original image.
    
    Args:
        original_img: Original image as numpy array (H, W, 3), uint8
        heatmap:      Grad-CAM heatmap (H, W), values in [0, 1]
        alpha:        Blending factor (0=original, 1=heatmap)
        colormap:     OpenCV colormap
    
    Returns:
        overlaid: Combined image as numpy array (H, W, 3), uint8
    """
    # Resize heatmap to image size
    heatmap_resized = cv2.resize(heatmap, (original_img.shape[1], original_img.shape[0]))
    heatmap_uint8   = (heatmap_resized * 255).astype(np.uint8)
    heatmap_colored = cv2.applyColorMap(heatmap_uint8, colormap)
    heatmap_rgb     = cv2.cvtColor(heatmap_colored, cv2.COLOR_BGR2RGB)
    
    # Blend
    overlaid = cv2.addWeighted(
        original_img.astype(np.float32), 1 - alpha,
        heatmap_rgb.astype(np.float32),  alpha,
        0
    ).astype(np.uint8)
    
    return overlaid


def generate_gradcam_visualization(
    model:       nn.Module,
    model_name:  str,
    image_path:  str,
    save_dir:    Path = None,
    transform    = None,
) -> dict:
    """
    Full Grad-CAM visualization pipeline for a single image.
    
    Returns:
        dict with: heatmap, overlaid image, prediction, confidence
    """
    from src.data.dataset_loader import get_transforms
    
    save_dir   = save_dir or PATHS["gradcam_dir"]
    save_dir   = Path(save_dir)
    save_dir.mkdir(parents=True, exist_ok=True)
    
    transform  = transform or get_transforms("test")
    
    # Load and preprocess image
    original   = Image.open(image_path).convert("RGB")
    orig_np    = np.array(original)
    input_t    = transform(original).unsqueeze(0).to(DEVICE)
    input_t.requires_grad_(True)
    
    # Get target layer
    target_layer = get_target_layer(model, model_name)
    
    # Create GradCAM instance
    gradcam = GradCAM(model, target_layer)
    
    # Generate heatmap
    heatmap, pred_class, probs = gradcam.generate(input_t)
    
    # Overlay heatmap on original image
    orig_resized = cv2.resize(orig_np, (IMAGE["size"], IMAGE["size"]))
    overlaid     = apply_heatmap_to_image(orig_resized, heatmap)
    
    class_names  = DATASET["classes"]
    prediction   = class_names[pred_class]
    confidence   = float(probs[pred_class])
    
    # ── Create Figure ─────────────────────────────────────────────
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle(
        f"Grad-CAM Explainability — {model_name.upper()}\n"
        f"Prediction: {prediction.upper()} (Confidence: {confidence*100:.1f}%)",
        fontsize=13, fontweight="bold"
    )
    
    # Original
    axes[0].imshow(orig_resized)
    axes[0].set_title("Original OCT Image", fontsize=11)
    axes[0].axis("off")
    
    # Heatmap
    heatmap_resized = cv2.resize(heatmap, (IMAGE["size"], IMAGE["size"]))
    im = axes[1].imshow(heatmap_resized, cmap="jet", vmin=0, vmax=1)
    axes[1].set_title("Grad-CAM Heatmap\n(Red = High Attention)", fontsize=11)
    axes[1].axis("off")
    plt.colorbar(im, ax=axes[1], fraction=0.046, pad=0.04)
    
    # Overlay
    axes[2].imshow(overlaid)
    axes[2].set_title("Heatmap Overlay\n(Regions Influencing Decision)", fontsize=11)
    axes[2].axis("off")
    
    # Add probability bar
    probs_to_show = probs[:len(class_names)]
    colors        = ["#4CAF50" if i == pred_class else "#F44336"
                     for i in range(len(class_names))]
    
    for i, (cls, p, c) in enumerate(zip(class_names, probs_to_show, colors)):
        axes[2].text(
            0.02, 0.02 + i * 0.08,
            f"{cls.capitalize()}: {p*100:.1f}%",
            transform=axes[2].transAxes,
            fontsize=10, color="white",
            bbox=dict(boxstyle="round,pad=0.2", facecolor=c, alpha=0.7),
        )
    
    plt.tight_layout()
    
    # Save
    stem      = Path(image_path).stem
    save_path = save_dir / f"gradcam_{model_name}_{stem}.png"
    plt.savefig(save_path, dpi=150, bbox_inches="tight")
    plt.close()
    
    # Also save just the heatmap overlay as PNG for web app
    overlay_path = save_dir / f"overlay_{model_name}_{stem}.png"
    Image.fromarray(overlaid).save(overlay_path)
    
    return {
        "heatmap":      heatmap,
        "overlaid":     overlaid,
        "prediction":   prediction,
        "confidence":   confidence,
        "probabilities": probs.tolist(),
        "save_path":    str(save_path),
        "overlay_path": str(overlay_path),
    }
