"""
======================================================================
  Dataset Loader — Kaggle OCT Glaucoma Detection Dataset
======================================================================
  Handles: Kaggle API download, extraction, train/val/test split,
           PyTorch Dataset class, DataLoader creation
======================================================================
"""

import os
import sys
import shutil
import zipfile
import random
from pathlib import Path
from typing import Tuple, Optional

import torch
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from PIL import Image
import numpy as np
from tqdm import tqdm

# Add project root to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import DATASET, IMAGE, TRAIN, PATHS, DEVICE


# ── Step 1: Kaggle API Download ──────────────────────────────────────
def download_dataset():
    """
    Download Glaucoma Detection dataset from Kaggle.
    Requires kaggle.json in ~/.kaggle/ or KAGGLE_USERNAME + KAGGLE_KEY env vars.
    
    SETUP INSTRUCTIONS:
    1. Go to https://www.kaggle.com/settings → API → Create New Token
    2. Download kaggle.json  
    3. Place at: C:/Users/<YourName>/.kaggle/kaggle.json
    4. Then run this script
    """
    raw_dir = DATASET["raw_dir"]
    raw_dir.mkdir(parents=True, exist_ok=True)
    
    zip_path = raw_dir / "glaucoma-detection.zip"
    
    if zip_path.exists():
        print(f"✅ Dataset zip already exists at {zip_path}")
    else:
        print("📥 Downloading dataset from Kaggle...")
        print("   Dataset: sshikamaru/glaucoma-detection (~400MB)")
        os.system(
            f'kaggle datasets download -d {DATASET["kaggle_dataset"]} '
            f'-p "{raw_dir}" --unzip'
        )
        print("✅ Download complete.")
    
    return raw_dir


# ── Step 2: Extract & Organise ───────────────────────────────────────
def extract_and_organise(raw_dir: Path) -> Path:
    """
    Finds the train/test folders in the extracted dataset and
    returns the path containing glaucoma/normal subfolders.
    """
    # Look for common structures in the dataset
    possible_roots = list(raw_dir.rglob("train")) + list(raw_dir.rglob("Train"))
    
    if not possible_roots:
        # Dataset might already be at root level
        if (raw_dir / "glaucoma").exists() or (raw_dir / "Glaucoma").exists():
            return raw_dir
        else:
            print("⚠️  Could not auto-detect dataset structure.")
            print(f"   Please check: {raw_dir}")
            print("   Expected: train/glaucoma/ and train/normal/ folders")
            return raw_dir
    
    source_dir = possible_roots[0]
    print(f"✅ Found dataset at: {source_dir}")
    return source_dir


# ── Step 3: Train/Val/Test Split ─────────────────────────────────────
def create_splits(source_dir: Path, force: bool = False):
    """
    Creates stratified train/val/test split from source datasets (ACRIMA, Fundus, ORIGA).
    Copies files to processed/{train,val,test}/{normal,glaucoma}/
    """
    processed_dir = DATASET["processed_dir"]
    
    # Check if already split
    train_glaucoma = DATASET["train_dir"] / "glaucoma"
    if train_glaucoma.exists() and any(train_glaucoma.iterdir()) and not force:
        print("✅ Dataset splits already exist. Skipping split creation.")
        return
    
    print("\n📂 Creating Train/Val/Test splits...")
    
    # Create directory structure
    for split in ["train", "val", "test"]:
        for cls in DATASET["classes"]:
            (processed_dir / split / cls).mkdir(parents=True, exist_ok=True)
            
    # Lists to store paths for each class
    normal_images = []
    glaucoma_images = []
    
    raw_dir = DATASET["raw_dir"]
    
    # 1. Process ACRIMA
    acrima_dir = raw_dir / "ACRIMA"
    if acrima_dir.exists():
        print("🔍 Scanning ACRIMA dataset...")
        for ext in ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.tiff"]:
            for img_path in acrima_dir.rglob(ext):
                # Classify by filename contains '_g_'
                if "_g_" in img_path.name.lower():
                    glaucoma_images.append(("acrima", img_path))
                else:
                    normal_images.append(("acrima", img_path))
                    
    # 2. Process Fundus_Train_Val_Data
    fundus_dir = raw_dir / "Fundus_Train_Val_Data"
    if fundus_dir.exists():
        print("🔍 Scanning Fundus Train/Val dataset...")
        for ext in ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.tiff"]:
            for img_path in fundus_dir.rglob(ext):
                path_str = str(img_path).replace("\\", "/")
                if "glaucoma_positive" in path_str.lower():
                    glaucoma_images.append(("fundus", img_path))
                elif "glaucoma_negative" in path_str.lower():
                    normal_images.append(("fundus", img_path))

    # 3. Process ORIGA
    origa_dir = raw_dir / "ORIGA"
    csv_path = raw_dir / "glaucoma.csv"
    if origa_dir.exists() and csv_path.exists():
        print("🔍 Scanning ORIGA dataset with glaucoma.csv...")
        try:
            import pandas as pd
            df = pd.read_csv(csv_path)
            # Create a lookup mapping from Filename to Glaucoma status
            lookup = dict(zip(df["Filename"].astype(str), df["Glaucoma"]))
            for ext in ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.tiff"]:
                for img_path in origa_dir.rglob(ext):
                    name = img_path.name
                    if name in lookup:
                        status = lookup[name]
                        if status == 1:
                            glaucoma_images.append(("origa", img_path))
                        else:
                            normal_images.append(("origa", img_path))
        except Exception as e:
            print(f"⚠️ Error reading ORIGA/glaucoma.csv: {e}")
            
    print(f"Total scans collected: Glaucoma={len(glaucoma_images)}, Normal={len(normal_images)}")
    
    if len(glaucoma_images) == 0 or len(normal_images) == 0:
        raise ValueError("Error: Found zero images for glaucoma or normal class. Cannot create splits.")
    
    random.seed(TRAIN["seed"])
    
    # Shuffle lists
    random.shuffle(glaucoma_images)
    random.shuffle(normal_images)
    
    # Split glaucoma
    n_g = len(glaucoma_images)
    n_g_train = int(n_g * TRAIN["train_split"])
    n_g_val = int(n_g * TRAIN["val_split"])
    
    g_splits = {
        "train": glaucoma_images[:n_g_train],
        "val": glaucoma_images[n_g_train:n_g_train + n_g_val],
        "test": glaucoma_images[n_g_train + n_g_val:],
    }
    
    # Split normal
    n_n = len(normal_images)
    n_n_train = int(n_n * TRAIN["train_split"])
    n_n_val = int(n_n * TRAIN["val_split"])
    
    n_splits = {
        "train": normal_images[:n_n_train],
        "val": normal_images[n_n_train:n_n_train + n_n_val],
        "test": normal_images[n_n_train + n_n_val:],
    }
    
    # Copy files
    for split_name in ["train", "val", "test"]:
        # Glaucoma
        dest_g = processed_dir / split_name / "glaucoma"
        print(f"  Copying {split_name} Glaucoma ({len(g_splits[split_name])} images)...")
        for dataset_name, img_path in tqdm(g_splits[split_name], desc=f"    Glaucoma {split_name}", leave=False):
            new_name = f"{dataset_name}_{img_path.name}"
            shutil.copy2(img_path, dest_g / new_name)
            
        # Normal
        dest_n = processed_dir / split_name / "normal"
        print(f"  Copying {split_name} Normal ({len(n_splits[split_name])} images)...")
        for dataset_name, img_path in tqdm(n_splits[split_name], desc=f"    Normal {split_name}", leave=False):
            new_name = f"{dataset_name}_{img_path.name}"
            shutil.copy2(img_path, dest_n / new_name)
            
    print("\n✅ Dataset split complete!")
    _print_split_summary()


def _print_split_summary():
    """Print a summary table of the dataset split."""
    print("\n" + "="*55)
    print(f"  {'Split':<10} {'Normal':>10} {'Glaucoma':>10} {'Total':>10}")
    print("="*55)
    for split in ["train", "val", "test"]:
        counts = {}
        for cls in DATASET["classes"]:
            folder = DATASET["processed_dir"] / split / cls
            counts[cls] = len(list(folder.glob("*"))) if folder.exists() else 0
        total = sum(counts.values())
        print(f"  {split.capitalize():<10} {counts['normal']:>10} {counts['glaucoma']:>10} {total:>10}")
    print("="*55)


# ── Step 4: PyTorch Dataset Class ────────────────────────────────────
class GlaucomaDataset(Dataset):
    """
    Custom PyTorch Dataset for Glaucoma Detection.
    Supports CLAHE preprocessing and augmentation.
    """
    
    def __init__(
        self,
        root_dir: Path,
        transform=None,
        use_clahe: bool = True,
    ):
        self.root_dir  = Path(root_dir)
        self.transform = transform
        self.use_clahe = use_clahe
        
        self.images = []
        self.labels = []
        
        self._load_dataset()
    
    def _load_dataset(self):
        """Scan directory and load all image paths + labels."""
        for idx, cls in enumerate(DATASET["classes"]):
            cls_dir = self.root_dir / cls
            if not cls_dir.exists():
                print(f"⚠️  Missing class directory: {cls_dir}")
                continue
            
            for ext in ["*.jpg", "*.jpeg", "*.png", "*.bmp"]:
                for img_path in cls_dir.glob(ext):
                    self.images.append(str(img_path))
                    self.labels.append(idx)
        
        print(f"  Loaded {len(self.images)} images from {self.root_dir.name}")
    
    def __len__(self) -> int:
        return len(self.images)
    
    def __getitem__(self, idx: int) -> Tuple[torch.Tensor, int]:
        img_path = self.images[idx]
        label    = self.labels[idx]
        
        # Load image
        image = Image.open(img_path).convert("RGB")
        
        # Apply CLAHE preprocessing
        if self.use_clahe:
            image = self._apply_clahe(image)
        
        # Apply transforms
        if self.transform:
            image = self.transform(image)
        
        return image, label
    
    def _apply_clahe(self, image: Image.Image) -> Image.Image:
        """
        Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
        for enhanced optic disc visibility in retinal OCT images.
        """
        import cv2
        
        img_array = np.array(image)
        
        # Convert to LAB color space
        lab = cv2.cvtColor(img_array, cv2.COLOR_RGB2LAB)
        l_channel, a, b = cv2.split(lab)
        
        # Apply CLAHE to L channel only
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
        cl = clahe.apply(l_channel)
        
        # Merge and convert back
        enhanced = cv2.merge((cl, a, b))
        enhanced = cv2.cvtColor(enhanced, cv2.COLOR_LAB2RGB)
        
        return Image.fromarray(enhanced)
    
    def get_class_weights(self) -> torch.Tensor:
        """Compute class weights for handling class imbalance."""
        from collections import Counter
        counts = Counter(self.labels)
        total  = len(self.labels)
        weights = [total / (len(DATASET["classes"]) * counts[i])
                   for i in range(len(DATASET["classes"]))]
        return torch.tensor(weights, dtype=torch.float32)


# ── Step 5: Transforms ───────────────────────────────────────────────
def get_transforms(split: str = "train"):
    """Return augmentation transforms per split."""
    mean = IMAGE["mean"]
    std  = IMAGE["std"]
    size = IMAGE["size"]
    
    if split == "train":
        return transforms.Compose([
            transforms.Resize((size + 20, size + 20)),
            transforms.RandomCrop(size),
            transforms.RandomHorizontalFlip(p=0.5),
            transforms.RandomVerticalFlip(p=0.3),
            transforms.RandomRotation(degrees=15),
            transforms.ColorJitter(brightness=0.3, contrast=0.3, saturation=0.2),
            transforms.RandomGrayscale(p=0.05),
            transforms.ToTensor(),
            transforms.Normalize(mean=mean, std=std),
        ])
    else:
        return transforms.Compose([
            transforms.Resize((size, size)),
            transforms.ToTensor(),
            transforms.Normalize(mean=mean, std=std),
        ])


# ── Step 6: DataLoader Factory ───────────────────────────────────────
def get_dataloaders(
    batch_size: int = TRAIN["batch_size"],
    num_workers: int = TRAIN["num_workers"],
    use_clahe: bool = True,
) -> Tuple[DataLoader, DataLoader, DataLoader]:
    """
    Create and return train, val, test DataLoaders.
    
    Returns:
        (train_loader, val_loader, test_loader)
    """
    print("\n📦 Creating DataLoaders...")
    
    train_dataset = GlaucomaDataset(
        root_dir  = DATASET["train_dir"],
        transform = get_transforms("train"),
        use_clahe = use_clahe,
    )
    val_dataset = GlaucomaDataset(
        root_dir  = DATASET["val_dir"],
        transform = get_transforms("val"),
        use_clahe = use_clahe,
    )
    test_dataset = GlaucomaDataset(
        root_dir  = DATASET["test_dir"],
        transform = get_transforms("test"),
        use_clahe = use_clahe,
    )
    
    # Weighted sampler for class imbalance in training
    class_weights = train_dataset.get_class_weights().to(DEVICE)
    sample_weights = [class_weights[label].item() for label in train_dataset.labels]
    sampler = torch.utils.data.WeightedRandomSampler(
        weights     = sample_weights,
        num_samples = len(train_dataset),
        replacement = True,
    )
    
    train_loader = DataLoader(
        train_dataset,
        batch_size  = batch_size,
        sampler     = sampler,
        num_workers = num_workers,
        pin_memory  = TRAIN["pin_memory"],
    )
    val_loader = DataLoader(
        val_dataset,
        batch_size  = batch_size * 2,
        shuffle     = False,
        num_workers = num_workers,
        pin_memory  = TRAIN["pin_memory"],
    )
    test_loader = DataLoader(
        test_dataset,
        batch_size  = batch_size * 2,
        shuffle     = False,
        num_workers = num_workers,
        pin_memory  = TRAIN["pin_memory"],
    )
    
    print(f"  ✅ Train : {len(train_dataset):5d} images | {len(train_loader)} batches")
    print(f"  ✅ Val   : {len(val_dataset):5d} images | {len(val_loader)} batches")
    print(f"  ✅ Test  : {len(test_dataset):5d} images | {len(test_loader)} batches")
    
    return train_loader, val_loader, test_loader


# ── Main: Setup Pipeline ─────────────────────────────────────────────
if __name__ == "__main__":
    print("="*60)
    print("  GLAUCOMA DETECTION — Dataset Setup Pipeline")
    print("="*60)
    
    # Step 1: Download
    raw_dir = download_dataset()
    
    # Step 2: Organise
    source_dir = extract_and_organise(raw_dir)
    
    # Step 3: Split
    create_splits(source_dir)
    
    # Step 4: Test DataLoaders
    train_loader, val_loader, test_loader = get_dataloaders()
    
    # Quick sanity check
    batch_imgs, batch_labels = next(iter(train_loader))
    print(f"\n✅ Batch shape : {batch_imgs.shape}")
    print(f"   Labels      : {batch_labels.tolist()}")
    print(f"   Min / Max   : {batch_imgs.min():.3f} / {batch_imgs.max():.3f}")
    print("\n🎉 Dataset pipeline ready!")
