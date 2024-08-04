## Steps to bootstrap a new Mac

### 1. Install Apple's Command Line Tools, which are prerequisites for Git and Homebrew.

```zsh
xcode-select --install
```

### 2. Clone repo into new hidden directory.

##### ``Use SSH (if set up)...``

```zsh
git clone git@github.com:mijailmariano/dotfiles.git ~/.dotfiles
```

##### ``...or use HTTPS and switch remotes later.``

```zsh
git clone https://github.com/mijailmariano/dotfiles.git ~/.dotfiles
```


### 3. Create ``symlinks`` in the Home directory to the real files in the repo.

* There are better and less manual ways to do this;
* investigate install scripts and bootstrapping tools.

```zsh
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
```


### 4. Install Homebrew, followed by the software listed in the Brewfile.

* These could also be in an install script.
* Install Homebrew

```zsh
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

##### ``Then pass in the Brewfile location...``

```zsh
brew bundle --file ~/.dotfiles/Brewfile
```

##### ``...or move to the directory first.``

```zsh
cd ~/.dotfiles && brew bundle
```

### Additional Considerations
* Learn how to use [`defaults`](https://macos-defaults.com/#%F0%9F%99%8B-what-s-a-defaults-command) to record and restore System Preferences and other macOS configurations.
* Organize these growing steps into multiple script files.
* Automate symlinking and run script files with a bootstrapping tool like [Dotbot](https://github.com/anishathalye/dotbot).
* Revisit the list in [`.zshrc`](.zshrc) to customize the shell.
* Make a checklist of steps to decommission your computer before wiping your hard drive.
* Create a [bootable USB installer for macOS](https://support.apple.com/en-us/HT201372).
* Integrate other cloud services into your Dotfiles process (Dropbox, Google Drive, etc.).
* Find inspiration and examples in other Dotfiles repositories at [dotfiles.github.io](https://dotfiles.github.io/).