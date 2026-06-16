#!/bin/bash

read -p "Enter project name: " input
PROJECT_DIR="attendance_tracker_${input}"


handle_interrupt() {
    echo ""
    echo "Interrupt detected! Archiving and cleaning up..."
    tar -czf "attendance_tracker_${input}_archive.tar.gz" "$PROJECT_DIR"
    rm -rf "$PROJECT_DIR"
    echo "Archive created: attendance_tracker_${input}_tar.gz"
    echo "Incomplete directory removed. Exiting."
    exit 1
}


trap 'handle_interrupt' SIGINT


echo "Creating project directory structure..."
mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"


# creating attendance_checker.py file
cat > "$PROJECT_DIR/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if _name_ == "_main_":
    run_attendance_check()
EOF

#CONFIG.json file
cat > "$PROJECT_DIR/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

#assets.csv file
cat > "$PROJECT_DIR/Helpers/assets.csv" << 'EOF'
Names,Email,Attendance Count
Alice Johnson,alice@example.com,14
Bob Smith,bob@example.com,7
Charlie Davis,charlie@example.com,4
Diana Ross,diana@example.com,12
Edward King,edward@example.com,10
EOF

#reports.log file
cat > "$PROJECT_DIR/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your
attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie
Davis, your attendance is 26.7%. You will fail this class
EOF


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


echo ""
echo "✓ Project '$PROJECT_DIR' has been set up successfully!"

