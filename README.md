# 🎯 Veeam Tape Auto Import Script

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Veeam](https://img.shields.io/badge/Veeam-VBR%20v13-green.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status](https://img.shields.io/badge/Status-Production--Ready-success.svg)

## 📌 Overview
This script automates the tape import process in Veeam Backup & Replication environments.
It ensures that a Tape Library always has available media in the Free Pool.

## 🚀 Key Features
- Checks Free Pool availability
- Imports tape only when needed
- Runs inventory automatically
- Validates final state
- Supports multiple libraries
- PowerShell 7 + VBR v13 ready

## ⚙️ Requirements
- Veeam Backup & Replication v13+
- PowerShell 7+
- Windows Server
- Veeam Console installed

## ▶️ Usage
pwsh.exe -File .\vbr_tape_import.ps1

## 👨‍💻 Author
Juliano Luiz Cunha
https://github.com/julianscunha
