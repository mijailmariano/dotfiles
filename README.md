# Dotfiles

My Mac bootstrap notes and shared shell configuration. This is meant to be the
place I check when I need to rebuild a machine, remember where a config lives,
or reconnect the workbench/scripts setup I use across projects.

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

The setup script backs up existing files, installs the Homebrew bundle, and
links the tracked configs into the places macOS and command-line tools expect.

```zsh
bash ~/.dotfiles/scripts/setup.sh
```

The main backup location is:

```zsh
~/.backupConfigs/
```

Key files linked by the setup script:

* `~/.zshrc` -> `~/.dotfiles/configs/.zshrc`
* `~/.gitconfig` -> `~/.dotfiles/configs/.gitconfig`
* `~/.gitignore_global` -> `~/.dotfiles/configs/.gitignore_global`
* `~/.config/*` -> matching folders under `~/.dotfiles/configs/.config/`

```bash
source ~/.zshrc
```

Or just close and reopen the terminal.

## Workbench And Project Bootstrap

Machine setup lives here. Project setup mostly lives in the workbench.

Useful shell shortcuts:

* `wb` and `workbench` jump to `~/code/workbench`.
* `chat` launches `codex`.
* `bootstrap-ai` runs the workbench bootstrap script and passes through any
  arguments.

Workbench scripts I expect to have locally:

```zsh
~/code/workbench
└── scripts
    ├── bootstrap-ai-repo.sh
    └── parse_codex_jsonl.py
```

For a new project that should get the standard AI-agent files/scripts, run:

```zsh
bootstrap-ai /path/to/project
```

For project environment setup, run this from inside the project:

```zsh
~/.dotfiles/scripts/init-direnv.sh
```

That writes a project `.envrc` for the detected Python/tooling setup and runs
through the direnv allow flow. Keep project-specific agent files, generated
logs, and repo-local automation in the project or in `~/code/workbench`; this
repo should only keep the portable shell entry points and shared assumptions.

## WezTerm

WezTerm lives in dotfiles the same way the other `.config` folders do:

```zsh
~/.dotfiles/configs/.config/wezterm/wezterm.lua
~/.config/wezterm -> ~/.dotfiles/configs/.config/wezterm
```

The shared config should work across any computer or environment I bootstrap.
Anything that only belongs in one local setup goes here:

```zsh
~/.dotfiles/configs/.config/wezterm/wezterm.local.lua
```

WezTerm is the terminal config I expect to use day to day. The shell config only
loads iTerm shell integration when `TERM_PROGRAM` is `iTerm.app`, so WezTerm
does not get iTerm-specific shell integration sequences.

After bootstrapping a machine, these are the quick checks:

```zsh
test -L ~/.config/wezterm
wezterm --config-file ~/.config/wezterm/wezterm.lua show-keys --lua >/dev/null
```

## Karabiner-Elements

Karabiner-Elements is linked through the shared `.config` setup:

```zsh
~/.dotfiles/configs/.config/karabiner/karabiner.json
~/.config/karabiner -> ~/.dotfiles/configs/.config/karabiner
```

The expected terminal launcher is a complex modification that maps
left Option + left Command + Space to WezTerm:

```json
{
    "description": "Launch WezTerm with Option+Command+Space",
    "manipulators": [
        {
            "from": {
                "key_code": "spacebar",
                "modifiers": {
                    "mandatory": ["left_option", "left_command"],
                    "optional": ["any"]
                }
            },
            "to": [{ "shell_command": "open -a WezTerm" }],
            "type": "basic"
        }
    ]
}
```
