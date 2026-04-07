# Syncs this independent `abw` repo from `upstream/master` to local `master`,
# optionally pushes the result to `origin`, and returns to the original branch.
param(
    # Skip the final push when you only want to update local master.
    [switch]$NoPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Wrapper for git commands that only need success/failure.
function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

# Wrapper for git commands where we need the command output as a string.
function Get-GitOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }

    return ($output -join "`n").Trim()
}

# Always operate from the repository root so relative git behavior is consistent.
$repoRoot = Get-GitOutput -Arguments @("rev-parse", "--show-toplevel")
$currentLocation = (Get-Location).Path

if ($repoRoot -ne $currentLocation) {
    Set-Location $repoRoot
}

$null = Get-GitOutput -Arguments @("remote", "get-url", "origin")
$null = Get-GitOutput -Arguments @("remote", "get-url", "upstream")

# Refuse to sync over local edits so the fast-forward stays predictable.
$status = Get-GitOutput -Arguments @("status", "--porcelain")
if ($status) {
    throw "Working tree is not clean. Commit, stash, or discard changes before syncing."
}

# Remember the starting branch so we can return there after updating master.
$originalBranch = Get-GitOutput -Arguments @("branch", "--show-current")
if (-not $originalBranch) {
    throw "Detached HEAD is not supported. Check out a branch before syncing."
}

try {
    if ($originalBranch -ne "master") {
        Write-Host "Switching to master..."
        Invoke-Git -Arguments @("checkout", "master")
    }

    # Pull upstream refs first, then accept only a clean fast-forward of master.
    Write-Host "Fetching upstream..."
    Invoke-Git -Arguments @("fetch", "upstream", "--prune")

    Write-Host "Fast-forwarding master from upstream/master..."
    Invoke-Git -Arguments @("merge", "--ff-only", "upstream/master")

    # Push the synced branch to your independent GitHub repo unless disabled.
    if (-not $NoPush) {
        Write-Host "Pushing master to origin..."
        Invoke-Git -Arguments @("push", "origin", "master")
    }

    Write-Host "Sync complete."
}
finally {
    if ($originalBranch -ne "master") {
        Write-Host "Returning to $originalBranch..."
        Invoke-Git -Arguments @("checkout", $originalBranch)
    }
}
