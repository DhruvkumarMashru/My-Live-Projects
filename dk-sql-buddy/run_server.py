import uvicorn
import os
import sys

# Ensure dks_sql_buddy directory is on sys.path
sys.path.insert(0, os.path.dirname(__file__))

if __name__ == "__main__":
    print("==============================================================")
    print(" Starting DK's SQL Buddy Server...")
    print(" Server Host: http://localhost:8000")
    print("==============================================================")
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
