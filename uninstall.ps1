#region Variables
$username = [System.Environment]::UserName
$destinationDirectory = "C:\Users\$username\PowerToolkit"
$scriptsDirectory = Join-Path -Path $destinationDirectory -ChildPath "modules"
$settingsDirectory = Join-Path -Path $scriptsDirectory -ChildPath ".settings"
$initScript = Join-Path -Path $settingsDirectory -ChildPath "Initialize-PowerToolkit.psm1"
#endregion

#region Functions
function GetUserRole {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Output "This script requires administrative privileges. Please run as an administrator."
        exit
    }
}

function RemoveDirectories {
    Write-Output "Taking ownership of the directory: $destinationDirectory"
    takeown /r /f $destinationDirectory | Out-Null

    Write-Output "Granting full control to the directory: $destinationDirectory`n"
    icacls $destinationDirectory /grant *S-1-5-32-544:F /t /c /q | Out-Null

    Write-Output "Changing directory to C:\`n"
    Set-Location -Path C:\

    Write-Output "Removing the directory: $destinationDirectory"
    Remove-Item -Path $destinationDirectory -Recurse -Force
    Write-Output "Directory removal completed.`n"
}

function RemoveInitializationFromProfile {
    $profilePath = $PROFILE
    
    if (Test-Path $profilePath) {
        $profileContent = Get-Content -Path $profilePath
        $initCommandPattern = [regex]::Escape("Import-Module -Name `"$initScript`" -Global")

        # Filter out the line containing the initialization command
        $newProfileContent = $profileContent | Where-Object { $_ -notmatch $initCommandPattern }

        # Write the updated content back to the profile
        Set-Content -Path $profilePath -Value $newProfileContent
        Write-Output "Removed initialization script from profile: $initScript`n"
    }
    else {
        Write-Output "Profile file does not exist: $profilePath`n"
    }
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

function RemovePowerToolkitContent {
    if (Test-Path $destinationDirectory) {
        RemoveDirectories
        RemovePSModulePath
        RemoveInitializationFromProfile
        Write-Output "Finished removing directories and cleaning up environment variables."
    }
    else {
        Write-Output "The directory does not exist: $destinationDirectory"
    }
}
#endregion

#region Main
GetUserRole
RemovePowerToolkitContent
#endregion
