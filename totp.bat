@echo off
setlocal
if "%~1"=="" (
    echo Usage: drag a key file onto totp.bat
    pause
    exit /b
)
set "ps=%temp%\totp_tmp.ps1"
more +12 "%~f0" > "%ps%"
powershell -ExecutionPolicy Bypass -File "%ps%" "%~1"
del "%ps%"
exit /b

param([string]$keyfile)
Add-Type -AssemblyName System.Windows.Forms

if (-not $keyfile -or -not (Test-Path $keyfile)) { exit 1 }

$secret = (Get-Content $keyfile -Raw).Trim().ToUpper().TrimEnd('=')

$alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
$bits = ""
foreach ($char in $secret.ToCharArray()) {
    $bits += [Convert]::ToString($alphabet.IndexOf($char), 2).PadLeft(5, '0')
}
$keyBytes = New-Object byte[] ([Math]::Floor($bits.Length / 8))
for ($i = 0; $i -lt $keyBytes.Length; $i++) {
    $keyBytes[$i] = [Convert]::ToByte($bits.Substring($i * 8, 8), 2)
}

$hmac = New-Object System.Security.Cryptography.HMACSHA1 -Property @{ Key = $keyBytes }
$lastCode = ""

while ($true) {
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $remaining = 30 - ($now % 30)

    $counterBytes = [BitConverter]::GetBytes([long][Math]::Floor($now / 30))
    [Array]::Reverse($counterBytes)
    $hash = $hmac.ComputeHash($counterBytes)
    $offset = $hash[-1] -band 0x0F
    $raw = (($hash[$offset] -band 0x7F) -shl 24) -bor
           (($hash[$offset + 1] -band 0xFF) -shl 16) -bor
           (($hash[$offset + 2] -band 0xFF) -shl 8) -bor
           ($hash[$offset + 3] -band 0xFF)
    $code = ($raw % 1000000).ToString("D6")

    if ($code -ne $lastCode) {
        [System.Windows.Forms.Clipboard]::SetText($code)
        $lastCode = $code
        Clear-Host
        Write-Host $code
    }

    $host.UI.RawUI.WindowTitle = "Copied, expires in ${remaining}s"
    Start-Sleep -Milliseconds 500
}
