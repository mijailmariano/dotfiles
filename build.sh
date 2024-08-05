#!/bin/bash

# Function to print messages
print_message() {
    echo "====================================="
    echo "$1"
    echo "====================================="
}

# Check and backup config files
check_and_backup_configs() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="$HOME/.backupConfigs/$TIMESTAMP"
    mkdir -p "$BACKUP_DIR"
    
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"
    print_message "Checked and backed up existing .zshrc and .gitconfig files"
}

# Install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_message "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_message "Homebrew already installed"
    fi
}

# Install packages from Brewfile
install_packages() {
    if [ -f "$HOME/.dotfiles/Brewfile" ]; then
        print_message "Installing packages from Brewfile"
        brew bundle --file="$HOME/.dotfiles/Brewfile"
    else
        print_message "Brewfile not found, skipping package installation"
    fi
}

# Create symlinks
create_symlinks() {
    print_message "Creating symlinks"
    ln -sf "$HOME/.dotfiles/configs/.zshrc" "$HOME/.zshrc"
    ln -sf "$HOME/.dotfiles/configs/.gitconfig" "$HOME/.gitconfig"
}

# Main execution
print_message "Starting build process"

check_and_backup_configs
install_homebrew
install_packages
create_symlinks

print_message "Build process complete!"