. (Join-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -ChildPath "..\utils\Globals.ps1")

<#
.SYNOPSIS
Protects or lists folders by changing their attributes to hidden and system.

.DESCRIPTION
This function allows you to lock, unlock, or list folders' protection status by modifying their file attributes.
Locking makes a folder hidden and treated as a system folder. Unlocking removes these attributes.

.PARAMETER Action
Specifies the action to perform: 
- Lock: Protects the folder by setting hidden and system attributes.
- Unlock: Removes protection attributes.
- List: Lists all subfolders and shows which ones are protected.

.PARAMETER FolderPath
The path of the folder to protect, unlock, or list. Defaults to the current directory if not specified.

.EXAMPLE
Protect-Folder -Action Lock -FolderPath 'C:\SecretFolder'
Locks and protects the folder 'C:\SecretFolder'.

.EXAMPLE
Protect-Folder -Action Unlock -FolderPath 'C:\SecretFolder'
Unlocks and makes the folder 'C:\SecretFolder' visible.

.EXAMPLE
Protect-Folder -Action List
Lists all folders in the current directory and indicates which are protected.

.NOTES
The protection mechanism relies on Windows file attributes: Hidden (H) and System (S). 
To see hidden system folders, enable "Show hidden files" and uncheck "Hide protected operating system files" in Folder Options.

#>
function Protect-Folder {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Lock', 'Unlock', 'List')]
        [string]$Action,

        [string]$FolderPath = "."
    )

    $privateFolder = (Resolve-Path -Path $FolderPath -ErrorAction SilentlyContinue)?.Path

    if (-not $privateFolder) {
        Write-Host "Specified folder does not exist." -ForegroundColor Red
        return
    }

    if ($Action -eq "List") {
        $folders = Get-ChildItem -Path $FolderPath -Directory -Force

        foreach ($folder in $folders) {
            try {
                $attribs = (Get-Item -Path $folder.FullName -ErrorAction Stop).Attributes

                if ($attribs -band [System.IO.FileAttributes]::Hidden -and $attribs -band [System.IO.FileAttributes]::System) {
                    Write-Host "$($folder.Name) (protected)" -ForegroundColor Yellow
                } else {
                    Write-Host "$($folder.Name)"
                }
            } catch {
                Write-Host "$($folder.Name) (protected)" -ForegroundColor Yellow
            }
        }
        return
    }

    $Password = Read-Host "Enter password" -AsSecureString

    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $PasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr1)

    if ($Action -eq "Lock") {
        $inputPassSecure = Read-Host "Confirm password for Lock operation" -AsSecureString

        $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($inputPassSecure)
        $inputPassPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr2)

        if ($inputPassPlain -ne $PasswordPlain) {
            Write-Host "Incorrect password confirmation. Operation aborted." -ForegroundColor Red
            return
        }

        do {
            $cho = Read-Host "Are you sure you want to lock the folder? (Y/N)"
            $cho = $cho.Trim().ToUpper()
        } while ($cho -ne 'Y' -and $cho -ne 'N')

        if ($cho -eq 'N') {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            return
        }

        attrib +h +s $privateFolder

        Write-Host "Folder locked successfully." -ForegroundColor Green
        return
    }

    if ($Action -eq "Unlock") {
        attrib -h -s $privateFolder

        Write-Host "Folder unlocked successfully." -ForegroundColor Green
        return
    }

    Write-Host "Invalid action specified." -ForegroundColor Red
}

Export-ModuleMember -Function Protect-Folder
