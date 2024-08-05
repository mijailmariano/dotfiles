#!/bin/bash

# Function to print messages
print_message() {
    echo "====================================="
    echo "$1"
    echo "====================================="
}

# Create backup folder with timestamp
create_backup_folder() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="$HOME/.backupConfigs/$TIMESTAMP"
    mkdir -p "$BACKUP_DIR"
    print_message "Created backup directory: $BACKUP_DIR"
}

# Backup existing config files
backup_configs() {
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"
    print_message "Backed up existing .zshrc and .gitconfig files"
}

# Install Command Line Tools
install_command_line_tools() {
    if ! xcode-select -p &>/dev/null; then
        print_message "Installing Command Line Tools"
        xcode-select --install
        read -p "Press enter when the installation is complete"
    else
        print_message "Command Line Tools already installed"
    fi
}

# Move dotfiles repo to ~/.dotfiles
move_dotfiles_repo() {
    if [ "$PWD" != "$HOME/.dotfiles" ]; then
        print_message "Moving dotfiles repo to ~/.dotfiles"
        mv "$PWD" "$HOME/.dotfiles"
        cd "$HOME/.dotfiles" || exit
    else
        print_message "Dotfiles repo already in correct location"
    fi
}

# Main execution
print_message "Starting setup process"

create_backup_folder
backup_configs
install_command_line_tools
move_dotfiles_repo

print_message "Setup complete! You can now run build.sh"