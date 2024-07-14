param (
    [Parameter(Mandatory = $false)]
    [switch]$Directory,

    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Path,

    [Parameter(Mandatory = $false)]
    [string]$BackupLocation = "C:\Backups",

    [Parameter(Mandatory = $false)]
    [switch]$Help
)

function Show-Help {
    Write-Host "Usage: backup [-Directory] -Path <string> [-BackupLocation <string>] [-Help]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Directory       Indicates if the path is a directory. If not specified, the path is considered to be a file."
    Write-Host "  -Path            The path of the file or directory to backup. (Mandatory unless -Help is specified)"
    Write-Host "  -BackupLocation  The location where the backup will be stored. Default is C:\Backups."
    Write-Host "  -Help            Displays this help message."
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  backup -Directory -Path 'C:\MyFolder' -BackupLocation 'D:\Backups'"
    Write-Host "  backup -Path 'C:\MyFile.txt' -BackupLocation 'D:\Backups'"
}

function Backup-FileOrDirectory {
    param (
        [switch]$Directory,
        [string]$Path,
        [string]$BackupLocation
    )

    # Convert the Path to lowercase
    $lowercasePath = $Path.ToLower()

    # Private Variables
    Set-Variable -Name "archiveName" -Visibility Private

    # Checking if the path is a directory or a file
    if ($Directory.IsPresent) {
        if (-Not (Test-Path -Path $Path -PathType Container)) {
            Write-Host "The specified path is not a valid directory."
            exit
        }
        $item = Get-Item -Path $lowercasePath
        $archiveName = $item.BaseName.ToLower().Replace(' ', '-')
        Write-Host "Starting backup of the directory: $Path"
    } else {
        if (-Not (Test-Path -Path $Path -PathType Leaf)) {
            Write-Host "The specified path is not a valid file."
            exit
        }
        $item = Get-Item -Path $lowercasePath
        $archiveName = [System.IO.Path]::GetFileNameWithoutExtension($item.Name).ToLower().Replace(' ', '-')
        Write-Host "Starting backup of the file: $Path"
    }

    Write-Host "Backup location: $BackupLocation`n"

    # Create backup directory if it does not exist
    if (-Not (Test-Path -Path $BackupLocation -PathType Container)) {
        New-Item -Path $BackupLocation -ItemType Directory | Out-Null
        Write-Host "Created backup directory: $BackupLocation"
    }

    $zipPath = Join-Path -Path $BackupLocation -ChildPath "${archiveName}.zip"

    # Compress the file or directory
    Compress-Archive -Path $Path -DestinationPath $zipPath
    Write-Host "Backup completed successfully. Backup file created at: $zipPath"
}

# Show help if requested
if ($Help) {
    Show-Help
    exit
}

# Ensure Path is provided if not in help mode
if (-not $Path) {
    Write-Host "The Path parameter is mandatory unless -Help is specified."
    exit
}

# Execute backup
Backup-FileOrDirectory -Directory $Directory -Path $Path -BackupLocation $BackupLocation
