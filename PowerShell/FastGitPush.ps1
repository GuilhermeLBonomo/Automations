<#
.SYNOPSIS
    This script automates the process of committing and pushing changes to a Git repository.

.DESCRIPTION
    The script performs the following actions:
    1. Prompts for the repository path with .git.
    2. Validates if the provided path contains a .git directory.
    3. Moves to the repository directory.
    4. Gets the current date.
    5. Prompts for the commit name (optional).
    6. Executes git pull, git add, git commit, git push, and git status.
    7. Verifies if Git is installed.

.NOTES
    Script Name: FastGitPush.ps1
    Author: GuilhermeLBonomo
    Date: 2023-12-01

.EXAMPLE
    .\FastGitPush.ps1
#>

# Function to validate the repository path
function Validate-Repo {
    param (
        [string]$RepositoryPath
    )

    $defaultMessage = "[Default path: $(Get-Location)]"

    # Check if the .git directory exists and is readable
    while (-not (Test-Path "$RepositoryPath\.git") -or -not (Test-Path $RepositoryPath) -or -not (Test-Path "$RepositoryPath\.git" -PathType Container) -or -not (Test-Path $RepositoryPath -PathType Container)) {
        Write-Host "Error: $defaultMessage"
        Write-Host "The path does not exist, does not contain a .git directory, or we don't have read permission."

        # Ask if the user wants to create a new .git directory
        $createGit = Read-Host "Do you want to create a new .git directory? (y/n)"
        if ($createGit -eq "y") {
            # Attempt to initialize a new Git repository
            git init $RepositoryPath
            $gitAddOriginCommand = "git remote add origin <repository_url>"
            Write-Host "Git repository created. To associate it with a remote repository, use:"
            Write-Host "$gitAddOriginCommand"
            Exit
        }
        else {
            $RepositoryPath = Read-Host "Enter a new path or press Enter to terminate the program"
            if (-not $RepositoryPath) {
                Exit
            }
        }
    }

    # Check if the .git directory is associated with a repository
    $isInsideWorkTree = git -C $RepositoryPath rev-parse --is-inside-work-tree 2>$null
    if (-not $isInsideWorkTree) {
        Write-Host "The .git directory is not associated with a Git repository."

        # Suggest a command to associate it with a remote repository
        $gitAddOriginCommand = "git remote add origin <repository_url>"
        Write-Host "To associate it with a remote repository, use:"
        Write-Host "$gitAddOriginCommand"
        Exit
    }
}

# Function to get the repository path
function Get-RepoPath {
    $defaultMessage = "[Default path: $(Get-Location)]"
    Write-Host "Enter the repository path with .git:"
    Write-Host "$defaultMessage"
    $RepositoryPath = Read-Host

    # If the path is not provided, use the current directory
    if (-not $RepositoryPath) {
        $RepositoryPath = Get-Location
    }

    # Call the Validate-Repo function before trying to change to the directory
    Validate-Repo -RepositoryPath $RepositoryPath | Out-Null

    Set-Location -Path $RepositoryPath
}

# Function to show the default behavior
function Show-ExecuteGit {
    Write-Host "Default behavior:"
    Write-Host "Running git in the repository at: $(Get-Location)"
    Write-Host "Current time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
    Write-Host "Commands to be executed:"
    Write-Host "1. git status"
    Write-Host "2. git pull --merge origin main --allow-unrelated-histories"
    Write-Host "3. git add ."
    Write-Host "4. git status"
    Write-Host "5. git commit -am ""$Message"""
    Write-Host "6. git push origin main"
    Write-Host "7. git status"
}

# Function to perform Git operations
function Execute-Git {
    Show-ExecuteGit

    # Ask the user if they want to use the default behavior
    $useDefault = Read-Host "Do you want to use the default behavior? (y/n)"
    
    if ($useDefault -eq "y") {
        # Use the default behavior
        git status
        git pull origin main
        git add .
        git status
        git commit -am "$Message"
        git push origin main
        git status
    }
    else {
        # Ask the user for branch and merge preferences
        $targetBranch = Read-Host "Enter the name of the target branch (default: main)"
        $targetBranch = $targetBranch -or "main"

        $performMerge = Read-Host "Do you want to merge into a branch (y/n)?"
        if ($performMerge -eq "y") {
            git pull --merge origin $targetBranch --allow-unrelated-histories
        }
        else {
            git fetch origin
        }

        git add .
        git status
        git commit -am "$Message"
        git push origin $targetBranch
        git status
    }
}

# Check if Git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Please install git."
    Exit 1
}

# Get the repository path
Get-RepoPath

# Ask for the commit name
$Message = Read-Host "Enter the commit name: (Default: 'Commit: $current_date')"
$Message = $Message -or "Commit: $current_date"

# Perform Git operations
Execute-Git
