. .\utils\Globals.ps1

#region Functions
function GetUserRole {
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error -Message "ERROR: This script requires administrative privileges. Please run as an administrator." -Category PermissionDenied
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
        Write-Error -Message "ERROR: Profile file does not exist: $profilePath`n" -Category ObjectNotFound
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
        Write-Error -Message "ERROR: The directory does not exist: $destinationDirectory" -Category ObjectNotFound
    }
}
#endregion

#region Main
GetUserRole
RemovePowerToolkitContent
#endregion
