#!/bin/bash

# function to print messages
print_message() {
    echo "*******************************************"
    echo "$1"
    echo "*******************************************"
}

# create backup folder with timestamp
create_backup_folder() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_DIR="$HOME/.backupConfigs/$TIMESTAMP"
    mkdir -p "$BACKUP_DIR"
    print_message "Created backup directory: $BACKUP_DIR"
}

# backup existing config files
backup_configs() {
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"
    print_message "Backed up existing .zshrc and .gitconfig files"
}

# install Command Line Tools
install_command_line_tools() {
    if ! xcode-select -p &>/dev/null; then
        print_message "Installing Command Line Tools"
        xcode-select --install
        read -p "Press enter when the installation is complete"
    else
        print_message "Command Line Tools already installed"
    fi
}

# install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_message "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_message "Homebrew already installed"
    fi
}

# install packages from Brewfile
install_packages() {
    if [ -f "$HOME/.dotfiles/Brewfile" ]; then
        print_message "Installing packages from Brewfile"
        brew bundle --file="$HOME/.dotfiles/Brewfile"
    else
        print_message "Brewfile not found, skipping package installation"
    fi
}

# move dotfiles repo to ~/.dotfiles
move_dotfiles_repo() {
    if [ "$PWD" != "$HOME/.dotfiles" ]; then
        print_message "Moving dotfiles repo to ~/.dotfiles"
        mv "$PWD" "$HOME/.dotfiles"
        cd "$HOME/.dotfiles" || exit
    else
        print_message "Dotfiles repo already in correct location"
    fi
}

# symlink config files
symlink_configs() {
    print_message "Symlinking Config Files"
    ln -sf "$HOME/.dotfiles/configs/.zshrc" "$HOME/.zshrc"
    ln -sf "$HOME/.dotfiles/configs/.gitconfig" "$HOME/.gitconfig"
}

# main execution
print_message "Starting Setup Process"

create_backup_folder
backup_configs
install_command_line_tools
install_homebrew
install_packages
move_dotfiles_repo
symlink_configs

print_message "Setup Complete!"