#!/bin/bash

# General utility functions
current_date=$(date +"%Y-%m-%d")

error() {
    echo "Error: $1"
    exit 1
}

terminate() {
    local current_user
    current_user=$(whoami)
    echo "Function terminated by $current_user"
    exit 0
}

# Function to validate the repository path
validate_repo() {
    local default_message
    default_message="[Default path: $(pwd)]"

    while [ ! -d "$RepositoryPath/.git" ] || [ ! -r "$RepositoryPath" ]; do
        echo "Error: $default_message"
        echo "The path does not exist, does not contain a .git directory, or we don't have read permission."

        echo -n "Do you want to create a new .git directory? (y/n): "
        read -r create_git
        if [ "$create_git" == "y" ]; then
            git init "$RepositoryPath"
            git_add_origin_command="git remote add origin <repository_url>"
            echo "Git repository created. To associate it with a remote repository, use:"
            echo "$git_add_origin_command"
            terminate
        else
            echo "Enter a new path or press Enter to terminate the program:"
            read -r RepositoryPath
            [ -z "$RepositoryPath" ] && terminate
        fi
    done

    if ! git -C "$RepositoryPath" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "The .git directory is not associated with a Git repository."
        git_add_origin_command="git remote add origin <repository_url>"
        echo "To associate it with a remote repository, use:"
        echo "$git_add_origin_command"
        terminate
    fi
}

# Function to get the repository path
get_repo_path() {
    local default_message
    default_message="[Default path: $(pwd)]"
    echo -n "Enter the repository path with .git: "
    echo "$default_message"
    read -r RepositoryPath
    [ -z "$RepositoryPath" ] && RepositoryPath=$(pwd)
    validate_repo

    cd "$RepositoryPath" || error "Could not change to the provided directory."
}

# Function to show the default behavior
show_execute_git() {
    echo "Default behavior: "
    echo "Running git in the repository at: $(pwd)"
    echo "Current time: $(date +"%Y-%m-%d %H:%M:%S")"
    echo "Commands to be executed:"
    echo "1. git status"
    echo "2. git pull --merge origin main --allow-unrelated-histories"
    echo "3. git add ."
    echo "4. git status"
    echo "5. git commit -am \"$Message\""
    echo "6. git push origin main"
    echo "7. git status"
}

# Function to perform Git operations
execute_git() {
    show_execute_git
    echo "Do you want to use the default behavior? (y/n): "
    read -r use_default

    if [[ "$use_default" == "y" ]]; then
        echo "Chegou aqui 1"
        git status
        git pull origin main
        git add .
        git status
        git commit -am "$Message"
        git push origin main
        git status
    else
        echo "Chegou aqui 2"
        read -p "Enter the name of the target branch (default: main): " target_branch
        target_branch=${target_branch:-main}

        read -p "Do you want to merge into a branch (y/n)? " perform_merge

        if [[ "$perform_merge" == "y" ]]; then
            echo "Chegou aqui 3"
            git pull --merge origin "$target_branch" --allow-unrelated-histories
        else
            echo "Chegou aqui 4"
            git fetch origin
        fi
        echo "Chegou aqui 5"
        git add .
        git status
        git commit -am "$Message"
        git push origin "$target_branch"
        git status
    fi
}

# Get the repository path and check if Git is installed
command -v git >/dev/null || error "Git not found. Please install git."
get_repo_path

# Ask for the commit name
echo -n "Enter the commit name: [Default: 'Commit: $current_date'] "
read -r Message

# If the commit name is not provided, use the default
[ -z "$Message" ] && Message="Commit: $current_date"

# Perform Git operations
execute_git
