# Veeam Tape Auto Import Script

![PowerShell](https://img.shields.io/badge/PowerShell-7+-blue.svg)
![Veeam](https://img.shields.io/badge/Veeam-VBR%20v13-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## Overview

This script automates tape import operations in Veeam Backup & Replication environments.

It ensures that a Tape Library always has at least one available tape in the **Free Pool**, importing new media only when necessary.

---

## How It Works

1. Connects to the Veeam Backup Server  
2. Locates the specified Tape Library  
3. Checks the Free Pool  
4. If a tape exists → exits  
5. If empty → imports a new tape  
6. Runs inventory  
7. Validates if the tape is available in Free Pool  

---

## Requirements

- Veeam Backup & Replication v13+
- PowerShell 7+
- Windows Server
- Veeam Console installed

---

## Installation

Clone the repository:

```
git clone https://github.com/julianscunha/Veeam.Tape.Import.git
cd Veeam.Tape.Import
```

---

## Usage

```
pwsh.exe -File .\vbr_tape_import.ps1
```

---

## With parameters

```
pwsh.exe -File .\vbr_tape_import.ps1 `
    -Server "VBR01" `
    -LibraryName "IBM TS4300"
```

---

## Accept TLS Certificate (for remote execution)

```
pwsh.exe -File .\vbr_tape_import.ps1 `
    -Server "veeam01.domain.local" `
    -LibraryName "IBM TS4300" `
    -ForceAcceptTlsCertificate
```

---

## Parameters

| Parameter | Description | Default |
|----------|------------|--------|
| Server | Veeam server hostname | localhost |
| LibraryName | Tape library name | Required |
| LogPath | Log file path | C:\Temp\vbr_tape_import.log |
| ForceAcceptTlsCertificate | Ignore TLS warnings | Disabled |

---

## Log Output Example

```
2026-03-30 22:01:10 [INFO] Starting execution
2026-03-30 22:01:11 [INFO] Free Pool tapes: 0
2026-03-30 22:02:05 [SUCCESS] Import completed
2026-03-30 22:02:40 [SUCCESS] Tape available in Free Pool
```

---

## Important Notes

- The script does not import tapes unnecessarily  
- Inventory is required for tape recognition  
- Tape import requires I/E slot support  
- Designed for automation scenarios  

---

## Recommended Use Case

- Automated tape environments  
- Air-gapped backup workflows  
- Scheduled validation routines  
- Tape rotation processes  

---

## Scheduling Example (Windows Task Scheduler)

Program:
```
pwsh.exe
```

Arguments:
```
-File "C:\Scripts\vbr_tape_import.ps1"
```

Options:
- Run whether user is logged on or not  
- Run with highest privileges  

---

## Future Improvements

- Email alerts on failure  
- Monitoring integration  
- Multi-library support  
- Dry-run mode  

---

## License

MIT License

---

## References

https://helpcenter.veeam.com/docs/vbr/powershell/  
https://helpcenter.veeam.com/docs/vbr/userguide/tape_devices.html  
