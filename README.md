# Attendance Tracker Deployment Script

This project automates the setup of a Student Attendance Tracker using shell scripting.

# Author
MARWAT (mkaremera3_cell)

# Description
A shell script that creates a project workspace, configures attendance thresholds dynamically, and handles interruptions gracefully with automatic archiving.

# Features
- Automated Directory Creation: Creates proper project structure with Helpers/ and reports/ folders
- Dynamic Configuration: Updates attendance thresholds using sed for in-place editing
- Signal Handling: Catches Ctrl+C interrupts and creates archive before cleanup
- Environment Validation: Checks for Python 3 installation and verifies file structure

# Requirements
- Bash shell
- Python 3
- tar (for archiving)

# Files Included
- 'setup_project.sh' - Main deployment script
- 'attendance_checker.py' - Python attendance tracking application
- 'assets.csv' - Student data
- 'config.json' - Configuration file with thresholds
- 'reports.log' - Initial log file

# How to Run

# Normal Setup
  bash
./setup_project.sh


Follow the prompts:
1. Enter a project identifier (e.g., 'MARWAT')
2. Choose whether to update thresholds (y/n)
3. If yes, enter WARNING and FAILURE percentages

# Triggering Archive Feature
To test the archive functionality:
1. Run './setup_project.sh'
2. During any prompt, press 'Ctrl+C'
3. The script will:
   - Create an archive: attendance_tracker_{identifier}_archive.tar.gz`
   - Delete the incomplete directory
   - Exit cleanly

# Project Structure Created

attendance_tracker_{identifier}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log


# Configuration Thresholds
- Warning Threshold: Default 75% (students below this get a warning)
- Failure Threshold: Default 50% (students below this fail)

These can be customized during setup using sed for in-place editing.

# Testing the Application
After setup completes:
  bash
cd attendance_tracker_{identifier}
python3 attendance_checker.py


Check the results in 'reports/reports.log'

# Archive Contents
When interrupted with Ctrl+C, the archive contains the incomplete project state at the time of interruption.

To extract an archive:
  bash
tar -xzf attendance_tracker_{identifier}_archive.tar.gz


# Error Handling
- Validates project identifier is not empty
- Checks if directory already exists and prompts for overwrite
- Validates threshold inputs are numeric (0-100)
- Verifies Python 3 installation
- Confirms all required files are in place

# Learning Outcomes
- Shell scripting automation
- Signal handling with trap
- Stream editing with sed
- Directory manipulation
- Process management
