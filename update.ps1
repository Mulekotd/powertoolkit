#region Functions
function VerifyGitInstalled {
    $gitPath = (Get-Command git.exe -ErrorAction SilentlyContinue).Path
    
    if (-not $gitPath) {
        Write-Host "Git is not installed on this computer. Please install Git and try again.`n" -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "Git is installed at $gitPath`n"
    }
}

function UpdateGitRepository {
    Write-Host "Fetching latest changes..."
    git.exe fetch | Out-Null
    Write-Host "Pulling latest changes...`n"
    git.exe pull
}
#endregion

#region Main
VerifyGitInstalled
UpdateGitRepository
#endregion
