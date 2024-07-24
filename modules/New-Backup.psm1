. .\utils\Globals.ps1

<#
.SYNOPSIS
Backups a file or directory to a specified location.

.DESCRIPTION
This function compresses a specified file or directory into a ZIP archive and saves it to the designated backup location. 
It creates the backup directory if it does not already exist. 

.PARAMETER Directory
Indicates if the path is a directory. If this switch is specified, the path is treated as a directory. Otherwise, it is treated as a file.

.PARAMETER Path
The path of the file or directory to be backed up. This parameter is mandatory unless -Help is specified.

.PARAMETER BackupLocation
The location where the backup will be stored. The default location is "C:\Backups".

.EXAMPLE
New-Backup -Directory -Path 'C:\MyFolder' -BackupLocation 'D:\Backups'
Backups the specified directory 'C:\MyFolder' to 'D:\Backups'.

.EXAMPLE
New-Backup -Path 'C:\MyFile.txt' -BackupLocation 'D:\Backups'
Backups the specified file 'C:\MyFile.txt' to 'D:\Backups'.
#>
function New-Backup {
    param (
    [Parameter(Mandatory = $false)]
    [switch]$Directory,

    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Path,

    [Parameter(Mandatory = $false)]
    [string]$BackupLocation = $backupLocation,

    [Parameter(Mandatory = $false)]
    [switch]$Help
)
    $lowercasePath = $Path.ToLower()
    $archiveName = ""

    # Checking if the path is a directory or a file
    if ($Directory.IsPresent) {
        if (-Not (Test-Path -Path $Path -PathType Container)) {
            Write-Host "ERROR: The specified path is not a valid directory." -ForegroundColor Red
            exit
        }

        $item = Get-Item -Path $lowercasePath
        $archiveName = $item.BaseName.ToLower().Replace(' ', '-')
        Write-Output "Starting backup of the directory: $Path"
    } else {
        if (-Not (Test-Path -Path $Path -PathType Leaf)) {
            Write-Host "ERROR: The specified path is not a valid file." -ForegroundColor Red
            exit
        }

        $item = Get-Item -Path $lowercasePath
        $archiveName = [System.IO.Path]::GetFileNameWithoutExtension($item.Name).ToLower().Replace(' ', '-')
        Write-Output "Starting backup of the file: $Path"
    }

    Write-Output "Backup location: $BackupLocation`n"

    # Create backup directory if it does not exist
    if (-Not (Test-Path -Path $BackupLocation -PathType Container)) {
        New-Item -Path $BackupLocation -ItemType Directory | Out-Null
        Write-Output "Created backup directory: $BackupLocation"
    }

    $zipPath = Join-Path -Path $BackupLocation -ChildPath "${archiveName}.zip"

    # Compress the file or directory
    Compress-Archive -Path $Path -DestinationPath $zipPath
    Write-Output "Backup completed successfully. Backup file created at: $zipPath"
}

Export-ModuleMember -Function New-Backup
