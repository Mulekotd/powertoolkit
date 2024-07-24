#region Functions
function VerifyGitInstalled {
    $gitPath = (Get-Command git.exe -ErrorAction SilentlyContinue).Path

    if (-not $gitPath) {
        Write-Host "ERROR: Git is not installed on this computer. Please install Git and try again.`n" -ForegroundColor Red
        exit 1
    }
    else {
        Write-Output "Git is installed at $gitPath`n"
    }
}

function UpdateGitRepository {
    Write-Output "Fetching latest changes..."
    git.exe fetch | Out-Null
    Write-Output "Pulling latest changes...`n"
    git.exe pull
}
#endregion

#region Main
VerifyGitInstalled
UpdateGitRepository
#endregion
