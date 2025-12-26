# -----------------------------------------------------------------------------
# Powerlevel10k instant prompt (keep near the top)
# Anything that may prompt for input must go ABOVE this block.
# -----------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# PATH setup (keep in one place to avoid surprises)
# Order matters: earlier entries take precedence.
# -----------------------------------------------------------------------------
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)

# Tool-specific PATH additions
path+=(
  "$HOME/nifi-1.24.0/bin"
  /usr/local/sbin
  "/Applications/IntelliJ IDEA CE.app/Contents/MacOS"
)

# De-duplicate PATH entries while preserving order
typeset -U path
export PATH

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
# Note: zsh-syntax-highlighting should load last.
plugins=(
  git
  zsh-autosuggestions
  web-search
  zsh-syntax-highlighting
)

# Homebrew shell integration (sets brew-related env vars)
# Safe to run after PATH is set; it can add additional entries as needed.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Direnv (directory-scoped environment variables via .envrc)
# Keep ONLY this hook (do not also enable OMZ's direnv plugin).
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Remove stale Intel Homebrew completions path (avoids compinit _brew error)
fpath=(${fpath:#/usr/local/share/zsh/site-functions})

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# Prompt configuration (Powerlevel10k)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias ls="eza --icons=always"
alias jl="julia"
alias gsw='git switch $(git branch | fzf --preview "git log --oneline --color=always {} | head -20")'

# Keep pip aligned with the active python3 (Homebrew)
alias pip='python3 -m pip'
alias pip3='python3 -m pip'

# -----------------------------------------------------------------------------
# Python compatibility: make `python` work on macOS (maps to python3)
# Only define if `python` is not already installed.
# -----------------------------------------------------------------------------
if ! command -v python >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  python() { command python3 "$@"; }
fi

# -----------------------------------------------------------------------------
# Language / toolchain environment
# -----------------------------------------------------------------------------
export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home"

# -----------------------------------------------------------------------------
# Optional: load user-specific environment (if present)
# (Keep this late so it can override earlier defaults if needed.)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# -----------------------------------------------------------------------------
# Terminal integrations
# -----------------------------------------------------------------------------
[[ -f "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# -----------------------------------------------------------------------------
# Node Version Manager (nvm)
# -----------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
