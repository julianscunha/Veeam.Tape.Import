# 🎯 Veeam Tape Auto Import Script

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Veeam](https://img.shields.io/badge/Veeam-VBR%20v13-green.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status](https://img.shields.io/badge/Status-Production--Ready-success.svg)

---

## 📌 Overview

This script automates the tape import process in **Veeam Backup & Replication (VBR)** environments.

It ensures that a Tape Library always has available media in the **Free Pool**, importing a new tape only when required.

---

## 🚀 Key Features

- Checks if there are available tapes in the Free Pool
- Automatically imports new media when the pool is empty
- Runs inventory after import to recognize media
- Validates if the tape is successfully available
- Supports multiple tape libraries
- Compatible with VBR v13 and PowerShell 7
- Structured logging

---

## 🧠 How It Works

1. Connect to Veeam Backup Server  
2. Locate the Tape Library  
3. Check Free Pool  
4. If empty → Import tape  
5. Run inventory  
6. Validate Free Pool again  

---

## ⚙️ Requirements

- Veeam Backup & Replication v13+
- PowerShell 7+
- Windows Server
- Veeam Console installed

---

## ▶️ Usage

pwsh.exe -File .\vbr_tape_import.ps1

---

## 📊 Parameters

- Server (default: localhost)
- LibraryName (required)
- LogPath (default: C:\Temp\vbr_tape_import.log)
- ForceAcceptTlsCertificate

---

## 📁 Log Example

2026-03-30 22:01:10 [INFO] Start  
2026-03-30 22:01:11 [INFO] Free Pool: 0  
2026-03-30 22:02:05 [SUCCESS] Import completed  

---

## 👨‍💻 Author

Juliano Luiz Cunha  
https://github.com/julianscunha  

---

## 📄 License

MIT License
