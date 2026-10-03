"""
run.py — Quick launch script for GlaucoScan AI web application
Usage: python run.py
"""
import sys
from pathlib import Path

# Reconfigure stdout/stderr to UTF-8 to handle emojis on Windows
if sys.platform.startswith('win'):
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8')

sys.path.insert(0, str(Path(__file__).parent))

from config import create_directories, FLASK, DEVICE, GPU_INFO
create_directories()

print("="*60)
print("  🔬 GlaucoScan AI — Glaucoma Detection System")
print(f"  Device : {DEVICE}")
if GPU_INFO["available"]:
    print(f"  GPU    : {GPU_INFO['device_name']} ({GPU_INFO['vram_gb']} GB)")
print(f"  URL    : http://localhost:{FLASK['port']}")
print("="*60 + "\n")

from webapp.app import app
app.run(host=FLASK["host"], port=FLASK["port"], debug=FLASK["debug"])
