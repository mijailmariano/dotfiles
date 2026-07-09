# Dotfiles

Mac bootstrap and shared shell configuration for personal development, AI-agent
workflows, project scripts, and terminal setup.

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
└── scripts
    ├── init-direnv.sh
    └── setup.sh
```

## Bootstrap A New Mac

### 1. Clone repo into new hidden directory

#### Quickstart

**``SSH``**

```zsh
git clone git@github.com:mijailmariano/dotfiles.git ~/.dotfiles
```

**``HTTPS``**

```zsh
git clone https://github.com/mijailmariano/dotfiles.git ~/.dotfiles
```

### 2. Run the setup script

***A note on ``Symlinks`` (symbolic links): these are similar to shortcuts or references to other directories. they're used to keep the actual dotfiles in one place (the repo) while the system looks for them in the default locations from the home directory.***

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

```bash
# to apply changes, run:
source ~/.zshrc # or close and restart the terminal
```

## Project And AI-Agent Bootstrap

This repo keeps machine bootstrap separate from project bootstrap:

* `scripts/setup.sh` prepares the Mac, installs Homebrew packages from the
  `Brewfile`, and links shared shell/config files into the home directory.
* `scripts/init-direnv.sh` prepares project-level `.envrc` files for Python and
  data projects. Run it inside a project directory when direnv should manage
  that project's virtual environment and environment variables.
* The shell aliases `wb` and `workbench` jump to `~/code/workbench`.
* The shell alias `chat` launches `codex`.
* The shell function `bootstrap-ai` calls
  `~/code/workbench/scripts/bootstrap-ai-repo.sh` and passes through any
  arguments.

Expected local layout:

```zsh
~/code/workbench
└── scripts
    ├── bootstrap-ai-repo.sh
    └── parse_codex_jsonl.py
```

Use this flow for AI-agent-enabled repositories:

```zsh
cd ~/code/workbench
bootstrap-ai /path/to/project
```

Keep project-specific agent files, generated logs, and repository-local
automation in the target project or in `~/code/workbench`; keep only portable
shell entry points and shared bootstrap assumptions in this dotfiles repo.
