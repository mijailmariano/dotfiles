## Steps to Bootstrap (Mac)

```zsh
.dotfiles
├── Brewfile
├── README.md
├── configs
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .gitignore_global
│   └── .config
│       └── ... additional config directories and setup files
└── setup.sh
```

#### 1. Clone repo into new hidden directory.

**``If setup, use SSH...``**

```zsh
git clone git@github.com:mijailmariano/dotfiles.git ~/.dotfiles
```

**``...Or using HTTPS (can always change remotes later)``**

```zsh
git clone https://github.com/mijailmariano/dotfiles.git ~/.dotfiles
```

#### 2. Run the setup script

***A note on ``Symlinks`` (symbolic links): these are similar to shortcuts. they are used to keep the actual dotfiles in one place (the repo) while the system looks for them in the default locations from the home directory.***

```zsh
bash ~/.dotfiles/scripts/setup.sh
```

``setup script will:``
* Create a timestamped backup of your existing configurations in ~/.backupConfigs/
* Install Command Line Tools (if not already installed)
* Install Homebrew (if not already installed)
* Install packages from your Brewfile (if present)
* Move the dotfiles repository to ~/.dotfiles (if necessary)
* Symlink all specified config files and directories from your dotfiles repo
* Leave any existing configurations not in your dotfiles untouched

``Notes:``
* Only configurations present in your dotfiles repo will be symlinked
* Existing configurations not in your dotfiles (e.g., gh) will remain unchanged
* Backups of your original configurations can be found in ~/.backupConfigs/[timestamp]/

_run source ~/.zshrc to apply changes or close and restart the terminal_