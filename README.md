# 2fa-bat

[中文说明](README.zh-CN.md)

Minimal drag-and-drop TOTP authenticator for Windows. Single `.bat` file, no install needed.

## What it does

- Generates standard 6-digit TOTP codes (RFC 6238)
- Auto-copies to clipboard on each refresh
- Shows remaining valid time in the window title
- Runs in a loop until you close the window

## Usage

1. Save your Base32 secret key in a text file (one key per file, any extension)
2. Drag the key file onto `totp.bat`
3. The code appears in the console and is copied to your clipboard

## How to get your secret key

When enabling 2FA on a service, look for the manual entry option near the QR code:

- **GitHub**: Settings → Password and authentication → click **"setup key"** below the QR code
- **GitLab**: Edit profile → Account → Register authenticator → the key is displayed next to the QR code

Copy the Base32 key (letters A-Z and digits 2-7) and save it to a text file, e.g. `github-junanchn.txt`.

## Requirements

- Windows 10 or later
- PowerShell 5.1+ (included with Windows)

## How it works

`totp.bat` is a hybrid file: the top section is batch script, the rest is PowerShell. On launch, the batch portion extracts the PowerShell code from itself into a temporary `.ps1` file, runs it, and cleans up.

The PowerShell code implements TOTP from scratch: Base32 decode → HMAC-SHA1 → dynamic truncation → 6-digit code.
