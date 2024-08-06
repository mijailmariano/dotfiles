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
    [ -d "$HOME/.config" ] && cp -R "$HOME/.config" "$BACKUP_DIR/"
    [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"
    [ -f "$HOME/.gitignore_global" ] && cp "$HOME/.gitignore_global" "$BACKUP_DIR/"
    print_message "Backed up existing config files and directories"
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
    
    # Array of files to symlink
    items=(".zshrc" ".gitconfig" ".gitignore_global")
    
    for item in "${items[@]}"; do
        if [ -e "$HOME/.dotfiles/configs/$item" ]; then
            symlink_item "$HOME/.dotfiles/configs/$item" "$HOME/$item"
        else
            echo "Warning: $item not found in dotfiles, skipping"
        fi
    done

    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"

    # Symlink .config subdirectories
    if [ -d "$HOME/.dotfiles/configs/.config" ]; then
        for dir in "$HOME/.dotfiles/configs/.config"/*; do
            if [ -d "$dir" ]; then
                basename=$(basename "$dir")
                symlink_item "$dir" "$HOME/.config/$basename"
            fi
        done
    else
        echo "Warning: .config directory not found in dotfiles, skipping"
    fi
}

symlink_item() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
        echo "Backed up existing $target to $BACKUP_DIR/$(basename "$target")"
    fi
    
    ln -sf "$source" "$target" || echo "Failed to symlink $source to $target"
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