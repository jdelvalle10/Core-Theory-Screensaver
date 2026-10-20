# Core Theory — Windows uninstaller (current user)
$ErrorActionPreference = 'Continue'
$dest = Join-Path $env:LOCALAPPDATA 'CoreTheory'

Get-Process CoreTheory -ErrorAction SilentlyContinue | Stop-Process -Force

# Unregister only if Core Theory is the current screensaver
$desk = 'HKCU:\Control Panel\Desktop'
$cur = (Get-ItemProperty $desk -ErrorAction SilentlyContinue).'SCRNSAVE.EXE'
if ($cur -and ($cur -match 'CoreTheory|CORETH~')) {
    Remove-ItemProperty $desk -Name 'SCRNSAVE.EXE'
    Add-Type -Namespace CT -Name Native -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool SystemParametersInfo(uint action, uint param, System.IntPtr vparam, uint flags);
'@
    [CT.Native]::SystemParametersInfo(0x0011, 0, [IntPtr]::Zero, 3) | Out-Null   # screensaver off
}

foreach ($dir in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
    Remove-Item (Join-Path $dir 'Core Theory.lnk') -ErrorAction SilentlyContinue
}
Start-Sleep -Milliseconds 500
Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Core Theory removed."
