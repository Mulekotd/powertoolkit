# User Variables
Set-Variable -Name "username" -Value ([System.Environment]::UserName) -Scope Global
Set-Variable -Name "currentUser" -Value (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())) -Scope Global
Set-Variable -Name "profilePath" -Value ($PROFILE) -Scope Global

# Directories Variables
Set-Variable -Name "backupLocation" -Value ("C:\Users\$username\.backups") -Scope Global
Set-Variable -Name "destinationDirectory" -Value ("C:\Users\$username\PowerToolkit") -Scope Global
Set-Variable -Name "scriptsDirectory" -Value (Join-Path -Path $destinationDirectory -ChildPath "modules") -Scope Global
Set-Variable -Name "settingsDirectory" -Value (Join-Path -Path $scriptsDirectory -ChildPath ".settings") -Scope Global

# Files Variables
Set-Variable -Name "initScript" -Value (Join-Path -Path $settingsDirectory -ChildPath "Initialize-PowerToolkit.psm1") -Scope Global

