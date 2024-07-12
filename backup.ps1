param (
    [Parameter(Mandatory = $false)]
    [switch]$Directory,

    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    [Parameter(Mandatory = $false)]
    [string]$BackupLocation = "C:\Backups"
)

# Convert the Path to lowercase
$lowercasePath = $Path.ToLower()

# Private Variables
Set-Variable -Name "archive_name" -Visibility Private

# TODO: Implement cloud storage with Google Drive

# Checking if the path is a directory or a file
if ($Directory.IsPresent) {
    if (-Not (Test-Path -Path $Path -PathType Container)) {
        Write-Host "The specified path is not a valid directory."
        exit
    }
    $item = Get-Item -Path $lowercasePath
    $archive_name = $item.BaseName.ToLower().Replace(' ', '-')
    Write-Host "Starting backup of the directory: $Path"
}
else {
    if (-Not (Test-Path -Path $Path -PathType Leaf)) {
        Write-Host "The specified path is not a valid file."
        exit
    }
    $item = Get-Item -Path $lowercasePath
    $archive_name = [System.IO.Path]::GetFileNameWithoutExtension($item.Name).ToLower().Replace(' ', '-')
    Write-Host "Starting backup of the file: $Path"
}

Write-Host "Backup location: $BackupLocation"

# Create backup directory if it does not exist
if (-Not (Test-Path -Path $BackupLocation -PathType Container)) {
    New-Item -Path $BackupLocation -ItemType Directory | Out-Null
    Write-Host "Created backup directory: $BackupLocation"
}

$zipPath = Join-Path -Path $BackupLocation -ChildPath "${archive_name}.zip"

# TODO: Use -Force or -Update fallback when file already exists
Compress-Archive -Path $Path -DestinationPath $zipPath

Write-Host "Backup completed successfully. Backup file created at: $zipPath"
