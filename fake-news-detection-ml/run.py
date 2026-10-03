"""
run.py — Quick launch script for Fake News Detection System web application
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

# Include root directory in system path
sys.path.insert(0, str(Path(__file__).parent))

from config import create_directories, FLASK
create_directories()

print("="*60)
print("  📰 Fake News Detection System — Web Workspace")
print(f"  URL    : http://{FLASK['host']}:{FLASK['port']}")
print("="*60 + "\n")

from webapp.app import app
app.run(host=FLASK["host"], port=FLASK["port"], debug=FLASK["debug"])
