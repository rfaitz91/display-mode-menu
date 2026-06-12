param(
    [ValidateSet("Menu", "Home", "Away", "InstallShortcut")]
    [string]$Mode = "Menu"
)

$ErrorActionPreference = "Stop"

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

function Install-DesktopShortcut {
    $scriptPath = $PSCommandPath
    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktop "Display Mode Menu.lnk"
    $powershellPath = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $powershellPath
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $shortcut.WorkingDirectory = Split-Path $scriptPath -Parent
    $shortcut.IconLocation = "$env:WINDIR\System32\Display.dll,0"
    $shortcut.Description = "Choose Home or Away display mode"
    $shortcut.Save()

    Write-Host "Created desktop shortcut: $shortcutPath"
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
    $form.ClientSize = New-Object System.Drawing.Size(320, 145)

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

    [void]$form.ShowDialog()
}

switch ($Mode) {
    "Home" { Set-DisplayTopology -Profile "Home" }
    "Away" { Set-DisplayTopology -Profile "Away" }
    "InstallShortcut" { Install-DesktopShortcut }
    default { Show-DisplayModeMenu }
}
