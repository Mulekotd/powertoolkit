#region Functions
function VerifyGitInstalled {
    $gitPath = (Get-Command git.exe -ErrorAction SilentlyContinue).Path

    if (-not $gitPath) {
        Write-Error -Message "ERROR: Git is not installed on this computer. Please install Git and try again." -Category NotInstalled
        exit 1
    }
    else {
        Write-Output "Git is installed at $gitPath`n"
    }
}

function UpdateGitRepository {
    Write-Output "Fetching latest changes..."
    git.exe fetch --all | Out-Null
    Write-Output "Pulling latest changes...`n"
    git.exe pull
}
#endregion

#region Main
VerifyGitInstalled
UpdateGitRepository
#endregion
