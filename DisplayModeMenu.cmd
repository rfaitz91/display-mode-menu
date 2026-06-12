@echo off
setlocal
set "DMM_CMD_PATH=%~f0"
set "DMM_MODE=%~1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$content = Get-Content -Raw -LiteralPath $env:DMM_CMD_PATH; $marker = '### POWERSHELL_START'; $index = $content.LastIndexOf($marker); if ($index -lt 0) { throw 'PowerShell section not found.' }; Invoke-Expression $content.Substring($index + $marker.Length)"
exit /b %ERRORLEVEL%

### POWERSHELL_START
$ErrorActionPreference = "Stop"

$mode = if ([string]::IsNullOrWhiteSpace($env:DMM_MODE)) { "Menu" } else { $env:DMM_MODE }
$validModes = @("Menu", "Home", "Away", "InstallShortcut")

if ($validModes -notcontains $mode) {
    throw "Unknown mode: $mode"
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class NativeDisplayConfig
{
    [DllImport("user32.dll")]
    public static extern int SetDisplayConfig(
        uint numPathArrayElements,
        IntPtr pathArray,
        uint numModeInfoArrayElements,
        IntPtr modeInfoArray,
        uint flags);
}
"@

function Set-DisplayTopology {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Home", "Away")]
        [string]$Profile
    )

    $SDC_TOPOLOGY_INTERNAL = 0x00000001
    $SDC_TOPOLOGY_EXTEND = 0x00000004
    $SDC_APPLY = 0x00000080

    $topologyFlag = switch ($Profile) {
        "Home" { $SDC_TOPOLOGY_EXTEND }
        "Away" { $SDC_TOPOLOGY_INTERNAL }
    }

    $result = [NativeDisplayConfig]::SetDisplayConfig(
        0,
        [IntPtr]::Zero,
        0,
        [IntPtr]::Zero,
        ($SDC_APPLY -bor $topologyFlag)
    )

    if ($result -ne 0) {
        throw "Windows could not apply the $Profile display profile. SetDisplayConfig returned error code $result."
    }
}

function New-ShortcutCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath
    )

    $escapedScriptPath = $ScriptPath.Replace("'", "''")
    $command = @"
`$env:DMM_CMD_PATH = '$escapedScriptPath'
`$env:DMM_MODE = 'Menu'
`$content = Get-Content -Raw -LiteralPath `$env:DMM_CMD_PATH
`$marker = '### ' + 'POWERSHELL_START'
`$index = `$content.LastIndexOf(`$marker)
if (`$index -lt 0) { throw 'PowerShell section not found.' }
Invoke-Expression `$content.Substring(`$index + `$marker.Length)
"@

    $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
    return [Convert]::ToBase64String($bytes)
}

function Install-DesktopShortcut {
    Add-Type -AssemblyName System.Windows.Forms

    $sourcePath = $env:DMM_CMD_PATH
    $installDirectory = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Display Mode Menu"
    $installedScriptPath = Join-Path $installDirectory "DisplayModeMenu.cmd"

    $message = @"
Install Display Mode Menu to:

$installDirectory

This will copy the app there and create or replace the desktop shortcut.
"@

    $choice = [System.Windows.Forms.MessageBox]::Show(
        $message,
        "Install Display Mode Menu",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($choice -ne [System.Windows.Forms.DialogResult]::Yes) {
        Write-Host "Install canceled."
        return
    }

    if (-not (Test-Path -LiteralPath $installDirectory)) {
        New-Item -Path $installDirectory -ItemType Directory | Out-Null
    }

    $sourceFullPath = [System.IO.Path]::GetFullPath($sourcePath)
    $destinationFullPath = [System.IO.Path]::GetFullPath($installedScriptPath)

    if (-not [string]::Equals($sourceFullPath, $destinationFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        Copy-Item -LiteralPath $sourcePath -Destination $installedScriptPath -Force
    }

    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktop "Display Mode Menu.lnk"
    $powershellPath = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
    $encodedCommand = New-ShortcutCommand -ScriptPath $installedScriptPath

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $powershellPath
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand $encodedCommand"
    $shortcut.WorkingDirectory = $installDirectory
    $shortcut.IconLocation = "$env:WINDIR\System32\Display.dll,0"
    $shortcut.Description = "Choose Home or Away display mode"
    $shortcut.Save()

    [System.Windows.Forms.MessageBox]::Show(
        "Installed to:`n$installDirectory`n`nCreated desktop shortcut:`n$shortcutPath",
        "Display Mode Menu",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Show-DisplayModeMenu {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Display Mode"
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.ClientSize = New-Object System.Drawing.Size(320, 190)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Choose a display profile:"
    $label.AutoSize = $true
    $label.Location = New-Object System.Drawing.Point(18, 18)
    $form.Controls.Add($label)

    $homeButton = New-Object System.Windows.Forms.Button
    $homeButton.Text = "Home - Enable all displays"
    $homeButton.Size = New-Object System.Drawing.Size(280, 34)
    $homeButton.Location = New-Object System.Drawing.Point(20, 48)
    $homeButton.Add_Click({
        try {
            Set-DisplayTopology -Profile "Home"
            $form.Close()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Display Mode", "OK", "Error") | Out-Null
        }
    })
    $form.Controls.Add($homeButton)

    $awayButton = New-Object System.Windows.Forms.Button
    $awayButton.Text = "Away - Primary display only"
    $awayButton.Size = New-Object System.Drawing.Size(280, 34)
    $awayButton.Location = New-Object System.Drawing.Point(20, 90)
    $awayButton.Add_Click({
        try {
            Set-DisplayTopology -Profile "Away"
            $form.Close()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Display Mode", "OK", "Error") | Out-Null
        }
    })
    $form.Controls.Add($awayButton)

    $installButton = New-Object System.Windows.Forms.Button
    $installButton.Text = "Install / Update Desktop Shortcut"
    $installButton.Size = New-Object System.Drawing.Size(280, 34)
    $installButton.Location = New-Object System.Drawing.Point(20, 132)
    $installButton.Add_Click({
        try {
            Install-DesktopShortcut
            $form.Close()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, "Display Mode", "OK", "Error") | Out-Null
        }
    })
    $form.Controls.Add($installButton)

    [void]$form.ShowDialog()
}

switch ($mode) {
    "Home" { Set-DisplayTopology -Profile "Home" }
    "Away" { Set-DisplayTopology -Profile "Away" }
    "InstallShortcut" { Install-DesktopShortcut }
    default { Show-DisplayModeMenu }
}
