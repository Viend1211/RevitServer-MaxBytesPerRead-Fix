# RevitServer-MaxBytesPerRead-Fix

Interactive configuration tool for Autodesk Revit Server.

This utility automatically detects installed Revit Server versions, allows selecting specific versions or all installations, and updates the `maxBytesPerRead` value inside Revit Server `web.config` files.

The tool can also restore the default Autodesk value.

---
## Why?

This tool is designed to improve Autodesk Revit Server performance by optimizing network read operations.

Increasing `maxBytesPerRead` can help:

- Faster model loading and synchronization
- Improved performance with large BIM files
- More stable work with heavy central models
- Reduced network overhead during data transfer
- Better responsiveness in multi-user environments

It is especially useful in environments with:

- Large Revit models
- WAN / remote office connections
- High collaboration load on Revit Server



## Features

- Detects all installed Revit Server versions
- Interactive version selection
- Supports:
  - Custom optimized value (`102400`)
  - Restore default value (`4096`)
- Automatically stops and restarts Revit Server services
- Creates `.bak` backup files
- Generates detailed logs
- Supports PowerShell and EXE deployment
- UTF-8 console support

---

## Supported Versions

Tested with:

- Revit Server 2020
- Revit Server 2021
- Revit Server 2022
- Revit Server 2023
- Revit Server 2024

---

## What Does It Change?

The tool modifies:

```xml
maxBytesPerRead="4096"
```

to:

```xml
maxBytesPerRead="102400"
```

inside:

```text
Services\ModelService\web.config
Services\LocalService\web.config
```

---

## Why?

Increasing `maxBytesPerRead` may improve:

- Revit Server synchronization performance
- Large model transfer stability
- WAN replication behavior
- Read throughput for large BIM projects

---

## Usage

Run as Administrator.

### PowerShell

```powershell
.\Fix-RevitServer.ps1
```

### EXE

```text
Fix-RevitServer.exe
```

---

## Interactive Menu

Example:

```text
[1] Revit Server 2022
[2] Revit Server 2024

[A] All versions

Select versions:
```

Then:

```text
[1] Set optimized value (102400)
[2] Restore Autodesk default (4096)
```

---

## Logs

The tool generates:

```text
RevitServerFix.log
```

Example:

```text
2026-05-16 15:44:11 - Processing:
C:\Program Files\Autodesk\Revit Server 2022\Services\ModelService\web.config

SUCCESS
```

---

## Backup Files

Automatic backups are created:

```text
web.config.bak
```

---

## Build EXE

Using PS2EXE:

```powershell
Install-Module ps2exe -Scope CurrentUser
Import-Module ps2exe

Invoke-PS2EXE `
".\Fix-RevitServer.ps1" `
".\Fix-RevitServer.exe"
```

---

## Disclaimer

Use at your own risk.

Always test configuration changes in a staging environment before production deployment.

This project is not affiliated with Autodesk.
