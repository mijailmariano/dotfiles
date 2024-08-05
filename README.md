## Steps to bootstrap a new Mac

```zsh
.dotfiles
├── Brewfile
├── README.md
├── configs
│   ├── .zshrc
│   └── .gitconfig
└── scripts
    ├── setup.sh
    └── build.sh
```

#### 1. Clone repo into new hidden directory.

**``Use SSH (if set up)...``**

```zsh
git clone git@github.com:mijailmariano/dotfiles.git
```

**``...or use HTTPS and switch remotes later.``**

```zsh
git clone https://github.com/mijailmariano/dotfiles.git
```

#### 2. Run the setup script

***Note on ``Symlinks`` (symbolic links): Similar to shortcuts. These will be used to keep our actual dotfiles in one place (the repo) while the system looks for them in the default locations.***

```zsh
bash ~/.dotfiles/scripts/setup.sh
```

``setup script will:``

* Creates a backup of existing config files
* Installs Command Line Tools (if not already installed)
* Moves the dotfiles repo to ~/.dotfiles (if necessary)
* Creates symlinks for the config files


#### 3. Run the build script

```zsh
bash ~/.dotfiles/scripts/build.sh
```

``build script will:``

* Checks and backup config files again (for safety)
* Installs Homebrew (if not already installed)
* Installs packages from the Brewfile
* Creates symlinks for the config files

_Restart your terminal or run source ~/.zshrc to apply changes._