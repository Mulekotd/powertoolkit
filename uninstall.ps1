#region Variables
$username = [System.Environment]::UserName

$destinationDirectory = "C:\Users\$username\PowerToolkit"
$scriptsDirectory = Join-Path -Path $destinationDirectory -ChildPath "modules"
#endregion

#region Functions
function Get-Role {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Output "This script requires administrative privileges. Please run as an administrator."
        exit
    }
}

function RemoveDirectories {
    $adminName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    Write-Output "Taking ownership of the directory: $destinationDirectory"
    takeown /r /f $destinationDirectory | Out-Null

    Write-Output "Granting full control to the directory: $destinationDirectory"
    icacls $destinationDirectory /grant *S-1-5-32-544:F /t /c /q | Out-Null

    Write-Output "`nChanging directory to C:\"
    Set-Location -Path C:\

    Write-Output "Removing the directory: $destinationDirectory"
    Remove-Item -Path $destinationDirectory -Recurse -Force
    Write-Output "Directory removal completed.`n"
}

function RemovePSModulePath {
    $currentPath = [System.Environment]::GetEnvironmentVariable('PSModulePath', [System.EnvironmentVariableTarget]::User)

    # Split the PSModulePath into an array of paths
    $pathArray = $currentPath -split ';'

    # Remove any entries that match the scriptsDirectory
    $newPathArray = $pathArray | Where-Object { $_ -ne $scriptsDirectory }

    # Join the array back into a single string
    $newPath = ($newPathArray -join ';')

    # Update the PSModulePath environment variable
    [System.Environment]::SetEnvironmentVariable('PSModulePath', $newPath, [System.EnvironmentVariableTarget]::User)
    Write-Output "Updated PSModulePath: $newPath"
}
#endregion

#region Main
Get-Role
RemoveDirectories
RemovePSModulePath
#endregion

Write-Output "Finished removing directories and cleaning up environment variables."
