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
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

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
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
