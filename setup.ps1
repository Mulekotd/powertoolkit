# Get the directory where the set_variables.ps1 script is located
$currentDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define the path to the destination directory in C:\PowerToolkit
$destinationDirectory = "C:\PowerToolkit"

# Ensure the source directory exists
if (-not (Test-Path -Path $currentDirectory)) {
    Write-Host "Source directory does not exist: $currentDirectory"
    exit
}

# Copy the current directory to C:\PowerToolkit if it doesn't exist
if (-not (Test-Path -Path $destinationDirectory)) {
    New-Item -Path $destinationDirectory -ItemType Directory | Out-Null
    Copy-Item -Path "$currentDirectory\*" -Destination $destinationDirectory -Recurse
    Write-Host "Copied directory: $currentDirectory to $destinationDirectory"
}

# Define the path to the 'modules' directory inside the destination directory
$scriptsDirectory = Join-Path -Path $destinationDirectory -ChildPath "modules"

# Define the path to the 'bin' directory inside the destination directory
$binDirectory = Join-Path -Path $destinationDirectory -ChildPath "bin"

# Create C:\PowerToolkit\bin if it doesn't exist
if (-not (Test-Path -Path $binDirectory)) {
    New-Item -Path $binDirectory -ItemType Directory | Out-Null
    Write-Host "Created directory: $binDirectory`n"
}

# Ensure the 'modules' directory exists before proceeding
if (-not (Test-Path -Path $scriptsDirectory)) {
    Write-Host "'modules' directory does not exist: $scriptsDirectory"
    exit
}

# Get all .ps1 files from the 'modules' directory
$scripts = Get-ChildItem -Path $scriptsDirectory -Filter *.ps1

foreach ($script in $scripts) {
    $name = $script.BaseName
    $value = $script.FullName
    
    # Create a corresponding .bat file for each .ps1 script in C:\PowerToolkit\bin
    $batFilePath = Join-Path -Path $binDirectory -ChildPath "$name.bat"
    $batContent = "@echo off`npowershell -ExecutionPolicy Bypass -File `"$value`" %*"
    Set-Content -Path $batFilePath -Value $batContent
    Write-Host "Created batch file: $batFilePath`n"
}

# Refresh the environment variables in the current PowerShell session
$env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)

# Check if the 'bin' directory is already in PATH
$pathEntries = $env:PATH.Split(';')
if (-not ($pathEntries -contains $binDirectory)) {
    # Add the 'bin' directory to the PATH environment variable
    $newPath = "$env:PATH;$binDirectory"
    [System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::User)
    Write-Host "Added directory to PATH: $binDirectory"
}
else {
    Write-Host "Directory already in PATH: $binDirectory"
}

Write-Host "Finished updating environment variables."
