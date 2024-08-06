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
git clone git@github.com:mijailmariano/dotfiles.git ~/.dotfiles
```

**``...or use HTTPS and switch remotes later.``**

```zsh
git clone https://github.com/mijailmariano/dotfiles.git ~/.dotfiles
```

#### 2. Run the setup script

***A note on ``Symlinks`` (symbolic links): these are similar to shortcuts. they are used to keep the actual dotfiles in one place (the repo) while the system looks for them in the default locations from the home directory.***

```zsh
bash ~/.dotfiles/scripts/setup.sh
```

``setup script will:``

* Create a backup folder to cache existing config files
* Install Command Line Tools (if not already installed)
* Install Homebrew (if not already installed)
* Install packages from the Brewfile
* Move the dotfiles repo to ~/.dotfiles (if necessary)
* Create symlinks for the config files


_run source ~/.zshrc to apply changes or close and restart the terminal_