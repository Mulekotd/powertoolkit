#region Variables
$username = [System.Environment]::UserName

$currentDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$destinationDirectory = "C:\Users\$username\PowerToolkit"

$scriptsDirectory = Join-Path -Path $destinationDirectory -ChildPath "modules"
$settingsDirectory = Join-Path -Path $scriptsDirectory -ChildPath ".settings"

# Create the initialization script
$initScriptContent = @"
# Import all modules from the specified directory
`$modulePath = '$scriptsDirectory'
Get-ChildItem -Path `$modulePath -Filter *.psm1 | ForEach-Object {
    Import-Module -Name `$_.FullName -Global
}
"@
#endregion

#region Functions
function Add-InitializationToProfile {
    # Define the path to the initialization script
    $initScript = Join-Path -Path $settingsDirectory -ChildPath "Initialize-PowerToolkit.psm1"
    
    if (Test-Path $initScript) {
        # Use double quotes inside the profile command for correct parsing
        $initCommand = "Import-Module -Name `"$initScript`" -Global"
        $profilePath = $PROFILE

        # Ensure the profile exists and create it if necessary
        if (-not (Test-Path $profilePath)) {
            New-Item -Path $profilePath -ItemType File -Force | Out-Null
        }

        # Read the profile content, initializing it as an empty string if not found
        $profileContent = if (Test-Path $profilePath) { Get-Content -Path $profilePath -Raw } else { "" }
        
        # Check if the initialization command is already in the profile
        if (-not $profileContent -or -not $profileContent.Contains($initCommand)) {
            Add-Content -Path $profilePath -Value $initCommand
            Write-Output "Added initialization script to profile: $initScript`n"
        } else {
            Write-Output "Initialization script is already in profile.`n"
        }
    } else {
        Write-Output "Initialization script not found: $initScript`n"
    }
}

function CreateDirectories {
    # Ensure the source directory exists
    if (-not (Test-Path -Path $currentDirectory)) {
        Write-Output "Source directory does not exist: $currentDirectory"
        exit
    }

    # Copy the current directory to the user's PowerToolkit directory and update if it already exists
    if (-not (Test-Path -Path $destinationDirectory)) {
        New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
        Write-Output "Created directory: $destinationDirectory"
    }

    # Update the contents of the user's PowerToolkit directory with the current directory
    Get-ChildItem -Path $currentDirectory -Recurse -Exclude '.git' | ForEach-Object {
        $destinationPath = $_.FullName -replace [regex]::Escape($currentDirectory), [regex]::Escape($destinationDirectory)
        if ($_.PSIsContainer) {
            if (-not (Test-Path -Path $destinationPath)) {
                New-Item -Path $destinationPath -ItemType Directory | Out-Null
            }
        } else {
            Copy-Item -Path $_.FullName -Destination $destinationPath -Force
        }
    }
    
    Write-Output "Updated directory: $currentDirectory to $destinationDirectory`n"

    # Create modules\.settings if it doesn't exist
    if (-not (Test-Path -Path $settingsDirectory)) {
        New-Item -Path $settingsDirectory -ItemType Directory | Out-Null
        Write-Output "Created directory: $settingsDirectory`n"
    }

    # Ensure the 'modules' directory exists before proceeding
    if (-not (Test-Path -Path $scriptsDirectory)) {
        Write-Output "'modules' directory does not exist: $scriptsDirectory"
        exit
    }
}

function GenerateInitializationScript {
    $initScriptPath = Join-Path -Path $settingsDirectory -ChildPath "Initialize-PowerToolkit.psm1"
    Set-Content -Path $initScriptPath -Value $initScriptContent
    Write-Output "Generated initialization script: $initScriptPath"
}

function ImportModules {
    # Get all .psm1 files from the 'modules' directory
    $modules = Get-ChildItem -Path $scriptsDirectory -Filter *.psm1

    foreach ($module in $modules) {
        $name = $module.BaseName
        $value = $module.FullName

        # Import each .psm1 module
        Import-Module -Name $value -Global
        Write-Output "Imported module: $name from $value`n"
    }
}

function UpdatePSModulePath {
    # Update PSModulePath environment variable
    $currentPath = [System.Environment]::GetEnvironmentVariable('PSModulePath', [System.EnvironmentVariableTarget]::User)
    
    # Initialize as empty string if null
    if (-not $currentPath) { 
        $currentPath = ""
    }

    # Ensure the path is properly formatted without leading semicolon
    if ($currentPath -eq "") {
        $newPath = $scriptsDirectory
    } elseif ($currentPath.Split(';') -notcontains $scriptsDirectory) {
        $newPath = "$currentPath;$scriptsDirectory"
    } else {
        $newPath = $currentPath
    }

    [System.Environment]::SetEnvironmentVariable('PSModulePath', $newPath, [System.EnvironmentVariableTarget]::User)
    Write-Output "Updated PSModulePath with: $newPath"
    Write-Output "Finished updating environment variables.`n"
}
#endregion

#region Main
CreateDirectories
GenerateInitializationScript
Add-InitializationToProfile
ImportModules
UpdatePSModulePath
#endregion
