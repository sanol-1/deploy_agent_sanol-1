#!/bin/bash

# --- Get User Input ---
read -p "Enter project name: " input
PROJECT_DIR="attendance_tracker_${input}"

# --- Cleanup Function for SIGINT ---
handle_interrupt() {
    echo ""
    echo "Interrupt detected! Archiving and cleaning up..."
    tar -czf "attendance_tracker_${input}_archive.tar.gz" "$PROJECT_DIR"
    rm -rf "$PROJECT_DIR"
    echo "Archive created: attendance_tracker_${input}_archive.tar.gz"
    echo "Incomplete directory removed. Exiting."
    exit 1
}

# --- Register the Trap ---
trap 'handle_interrupt' SIGINT

# --- Create Directory Structure ---
echo "Creating project directory structure..."
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

# --- Copy Source Files ---
cp attendance_checker.py "$PROJECT_DIR/"
cp assets.csv "$PROJECT_DIR/Helpers/"
cp config.json "$PROJECT_DIR/Helpers/"
cp reports.log "$PROJECT_DIR/reports/"

echo "Source files copied successfully."

# --- Dynamic Configuration ---
read -p "Do you want to update attendance thresholds? (y/n): " update_choice

if [ "$update_choice" == "y" ]; then
    read -p "Enter new Warning threshold (default 75): " warn_val
    read -p "Enter new Failure threshold (default 50): " fail_val

    sed -i "s/\"warning\": [0-9]*/\"warning\": ${warn_val}/" "$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": ${fail_val}/" "$PROJECT_DIR/Helpers/config.json"

    echo "Thresholds updated: Warning=${warn_val}%, Failure=${fail_val}%"
else
    echo "Keeping default thresholds: Warning=75%, Failure=50%"
fi

# --- Environment Validation ---
echo ""
echo "Running Health Check..."

if python3 --version &> /dev/null; then
    echo "✓ python3 is installed."
else
    echo "⚠ Warning: python3 was not found on this system."
fi

if [ -d "$PROJECT_DIR/Helpers" ] && [ -d "$PROJECT_DIR/reports" ] && [ -f "$PROJECT_DIR/attendance_checker.py" ]; then
    echo "✓ Directory structure verified."
else
    echo "✗ Something is missing in the project structure."
fi

# --- Done ---
echo ""
echo "✓ Project '$PROJECT_DIR' has been set up successfully!"
