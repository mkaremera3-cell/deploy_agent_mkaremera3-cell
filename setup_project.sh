#!/bin/bash

# ==========================================================
# Project Factory - Student Attendance Tracker
# Author: MARWAT DHUL HIJJA KAREMERA
# Description: Automated workspace creation with
#              configuration, signal handling, and validation
# ==========================================================

# -------------------------------
# GLOBAL VARIABLES
# -------------------------------
PROJECT_ID=""
PROJECT_DIR=""

# -------------------------------
# SIGNAL HANDLER (SIGINT)
# -------------------------------
handle_interrupt() {
    echo ""
    echo "Interrupt detected. Cleaning up..."

    if [ -d "$PROJECT_DIR" ]; then
        ARCHIVE_NAME="${PROJECT_DIR}_archive.tar.gz"

        echo "Archiving incomplete project..."
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo "Archive created: $ARCHIVE_NAME"
        else
            echo "Archive failed."
        fi

        rm -rf "$PROJECT_DIR"
        echo "Incomplete directory removed."
    fi

    echo "Exit."
    exit 1
}

trap handle_interrupt SIGINT

# -------------------------------
# USER INPUT
# -------------------------------
echo "==========================================="
echo "     Student Attendance Project Factory"
echo "==========================================="

read -p "Enter project identifier: " PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Identifier cannot be empty."
    exit 1
fi

PROJECT_DIR="attendance_tracker_${PROJECT_ID}"

# -------------------------------
# DIRECTORY CREATION
# -------------------------------
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

# -------------------------------
# GENERATE config.json
# -------------------------------
cat <<EOF > "$PROJECT_DIR/Helpers/config.json"
{
    "total_sessions": 30,
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live"
}
EOF

# -------------------------------
# GENERATE assets.csv
# -------------------------------
cat <<EOF > "$PROJECT_DIR/Helpers/assets.csv"
Email,Name,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# -------------------------------
# GENERATE attendance_checker.py
# -------------------------------
cat <<EOF > "$PROJECT_DIR/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(BASE_DIR, "Helpers", "config.json")
ASSETS_PATH = os.path.join(BASE_DIR, "Helpers", "assets.csv")
REPORTS_DIR = os.path.join(BASE_DIR, "reports")
REPORT_FILE = os.path.join(REPORTS_DIR, "reports.log")

def run_attendance_check():
    with open(CONFIG_PATH, "r") as f:
        config = json.load(f)

    total_sessions = config["total_sessions"]
    warning_threshold = config["thresholds"]["warning"]
    failure_threshold = config["thresholds"]["failure"]
    run_mode = config["run_mode"]

    if os.path.exists(REPORT_FILE):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        archive_name = os.path.join(REPORTS_DIR, f"reports_{timestamp}.log.archive")
        os.rename(REPORT_FILE, archive_name)

    with open(ASSETS_PATH, "r") as f, open(REPORT_FILE, "w") as log:
        reader = csv.DictReader(f)
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\\n")

        for row in reader:
            name = row["Name"]
            email = row["Email"]
            attended = int(row["Attendance Count"])

            attendance_pct = (attended / total_sessions) * 100
            message = ""

            if attendance_pct < failure_threshold:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < warning_threshold:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if run_mode == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# Create empty reports.log
touch "$PROJECT_DIR/reports/reports.log"

# -------------------------------
# DYNAMIC CONFIGURATION (SED)
# -------------------------------
echo ""
read -p "Do you want to update attendance thresholds? (y/n): " UPDATE

if [ "$UPDATE" = "y" ]; then
    read -p "Enter new WARNING threshold (default 75): " NEW_WARNING
    NEW_WARNING=${NEW_WARNING:-75}

    read -p "Enter new FAILURE threshold (default 50): " NEW_FAILURE
    NEW_FAILURE=${NEW_FAILURE:-50}

    CONFIG_FILE="$PROJECT_DIR/Helpers/config.json"

    sed -i "s/\"warning\": [0-9]*/\"warning\": $NEW_WARNING/" "$CONFIG_FILE"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $NEW_FAILURE/" "$CONFIG_FILE"

    echo "Thresholds updated."
else
    echo "Default thresholds retained."
fi

# -------------------------------
# ENVIRONMENT VALIDATION
# -------------------------------
echo ""
echo "Running system health check..."

if python3 --version > /dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version)
    echo "Python detected: $PYTHON_VERSION"
else
    echo "Warning: python3 is not installed."
fi

# Verify structure
if [ -f "$PROJECT_DIR/attendance_checker.py" ] && \
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] && \
   [ -f "$PROJECT_DIR/Helpers/config.json" ] && \
   [ -f "$PROJECT_DIR/reports/reports.log" ]; then
    echo "Directory structure verified."
else
    echo "Directory validation failed."
    exit 1
fi

# -------------------------------
# COMPLETION MESSAGE
# -------------------------------
echo ""
echo "==========================================="
echo "Project created successfully."
echo "Location: $PROJECT_DIR"
echo ""
echo "To run:"
echo "  cd $PROJECT_DIR"
echo "  python3 attendance_checker.py"
echo "==========================================="

