#!/bin/bash

# ============================================
# Author       : MARWAT DHUL HIJJA KAREMERA
# Date         : 2026-02-17
# Description  : Project Setup Script
# Version      : 1.0, means it is the first release of my script
# Project name : Automated Project Bootstrapping and process Manangement lab

# ============================================
# SETUP TASKS, what am going to do
# 1. Update my system and install the latest updates
# 2. Install the needed tools and software
# 3. Create the main project folder and sub folders ( directory)
# 4. Give the right access to files and folders (permissions)
# 5. Configure environment variables
# 6. Initialize version control (git)
# 7. Create a separate Python workspace 
# 8. Install the software libraries 
# 9. Run initial tests / health checks
# 10.Save a message with the date and time to confirm setup is done (completion)
# ============================================


# ============================================
# PROGRAM CONTROL (Signal Trap)
# ============================================
cleanup_on_interrupt() {
    echo ""
    echo "Setup interrupted! Cleaning up..."
    
    if [ -d "$PROJECT_DIR" ]; then
        # Create archive of incomplete project
        ARCHIVE_NAME="${PROJECT_DIR}_archive.tar.gz"
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Archived incomplete project to: $ARCHIVE_NAME"
        fi
        
        # Delete incomplete directory
        rm -rf "$PROJECT_DIR"
        echo "Removed incomplete directory: $PROJECT_DIR"
    fi
    
    echo "Cleanup complete. Exiting..."
    exit 1
}

# Set trap for SIGINT
trap cleanup_on_interrupt SIGINT

# ============================================
# MAIN SCRIPT
# ============================================
echo "======================================"
echo "  Student Attendance Tracker Setup"
echo "======================================"
echo ""

# Get project name from user
echo "Enter project identifier (e.g., 'MARWAT'):"
read PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Project identifier cannot be empty"
    exit 1
fi

PROJECT_DIR="attendance_tracker_${PROJECT_ID}"

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
    echo "Warning: Directory '$PROJECT_DIR' already exists"
    read -p "Do you want to overwrite it? (y/n): " OVERWRITE
    if [ "$OVERWRITE" != "y" ]; then
        echo "Setup cancelled."
        exit 0
    fi
    rm -rf "$PROJECT_DIR"
fi

# ============================================
# DIRECTORY STRUCTURE
# ============================================
echo ""
echo "Creating project structure..."

# Create directory structure
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

# Copy files to appropriate locations
cp attendance_checker.py "$PROJECT_DIR/"
cp assets.csv "$PROJECT_DIR/Helpers/"
cp config.json "$PROJECT_DIR/Helpers/"
cp reports.log "$PROJECT_DIR/reports/"

echo "Directory structure created successfully"

# ============================================
# DYNAMIC CONFIGURATION (Stream Editing)
# ============================================
echo ""
echo "Configuration Setup"
read -p "Do you want to update attendance thresholds? (y/n): " UPDATE_CONFIG

if [ "$UPDATE_CONFIG" = "y" ]; then
    echo ""
    
    # Get warning threshold
    while true; do
        read -p "Enter WARNING threshold percentage (default 75): " WARNING_THRESHOLD
        WARNING_THRESHOLD=${WARNING_THRESHOLD:-75}
        
        if [[ "$WARNING_THRESHOLD" =~ ^[0-9]+$ ]] && [ "$WARNING_THRESHOLD" -ge 0 ] && [ "$WARNING_THRESHOLD" -le 100 ]; then
            break
        else
            echo "Invalid input. Please enter a number between 0 and 100."
        fi
    done
    
    # Get failure threshold
    while true; do
        read -p "Enter FAILURE threshold percentage (default 50): " FAILURE_THRESHOLD
        FAILURE_THRESHOLD=${FAILURE_THRESHOLD:-50}
        
        if [[ "$FAILURE_THRESHOLD" =~ ^[0-9]+$ ]] && [ "$FAILURE_THRESHOLD" -ge 0 ] && [ "$FAILURE_THRESHOLD" -le 100 ]; then
            break
        else
            echo "Invalid input. Please enter a number between 0 and 100."
        fi
    done
    
    # Update config.json using sed (in-place editing)
    CONFIG_FILE="$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"warning\": [0-9]*/\"warning\": $WARNING_THRESHOLD/" "$CONFIG_FILE"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $FAILURE_THRESHOLD/" "$CONFIG_FILE"
    
    echo "Configuration updated: Warning=${WARNING_THRESHOLD}%, Failure=${FAILURE_THRESHOLD}%"
else
    echo "Using default thresholds: Warning=75%, Failure=50%"
fi

# ============================================
# ENVIRONMENT VALIDATION (Health Check)
# ============================================
echo ""
echo "Environment Validation"

# Check for Python 3
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "SUCCESS: Python 3 found - $PYTHON_VERSION"
else
    echo "WARNING: Python 3 is not installed on this system"
    echo "Please install Python 3 to run the attendance tracker"
fi

# Verify directory structure
echo ""
echo "Verifying directory structure..."
if [ -f "$PROJECT_DIR/attendance_checker.py" ] && \
   [ -f "$PROJECT_DIR/Helpers/assets.csv" ] && \
   [ -f "$PROJECT_DIR/Helpers/config.json" ] && \
   [ -f "$PROJECT_DIR/reports/reports.log" ]; then
    echo "SUCCESS: All required files are in place"
else
    echo "ERROR: Directory structure verification failed"
    exit 1
fi

# ============================================
# COMPLETION
# ============================================
echo ""
echo "======================================"
echo "Project setup complete!"
echo "======================================"
echo ""
echo "Project location: $PROJECT_DIR"
echo ""
echo "To run the attendance tracker:"
echo "  cd $PROJECT_DIR"
echo "  python3 attendance_checker.py"
echo ""
echo "To trigger archive feature: Press Ctrl+C during setup"
echo "======================================"
