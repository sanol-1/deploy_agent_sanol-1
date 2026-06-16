# deploy_agent_sanol-1
--- 

This repository is created and contains a script to build a "Project Factory"; a shell script that automates the creation of the workspace, configures settings via the command line, and handles system signals gracefully.

#Attendance Tracker Bootstrapper

The following is a shell script that automates the full setup of a Student Attendance Tracker workspace in one command.

HOW THIS WORKS: 
Enter a project name when prompted and follow the steps.

#What It Does

1. Creates `attendance_tracker_{name}/` with the required folder structure
2. Writes all source files into their correct locations
3. Optionally updates attendance thresholds in `config.json` using `sed`
4. Validates that `python3` is installed and the structure is complete

---

#Triggering the Archive Feature 

Press `Ctrl+C` at any point while the script is running. It will:
- Archive the current state into `attendance_tracker_{name}_archive.tar.gz`
- Delete the incomplete directory
- Exit cleanly. 

---

#How to Run
```bash
chmod +x setup_project.sh
```
```bash
./setup_project.sh
```
