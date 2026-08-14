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
alias wb='cd ~/code/workbench'
alias workbench='cd ~/code/workbench'
alias chat="codex"

unalias bootstrap-ai 2>/dev/null

bootstrap-ai() {

    ~/code/workbench/scripts/bootstrap-ai-repo.sh "$@"

}

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
if [[ "$TERM_PROGRAM" == "iTerm.app" && -f "${HOME}/.iterm2_shell_integration.zsh" ]]; then
  source "${HOME}/.iterm2_shell_integration.zsh"
fi
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# -----------------------------------------------------------------------------
# Node Version Manager (nvm)
# -----------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"

# -----------------------------------------------------------------------------
# Excalidraw Docker Image Bootstrap
# -----------------------------------------------------------------------------
excalidraw() {
  local container_name="excalidraw"
  local image_name="excalidraw/excalidraw:latest"
  local url="http://localhost:3000"

  # First, check whether the Docker CLI exists
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker CLI was not found. Make sure OrbStack is installed."
    return 1
  fi

  # Second, start OrbStack if the Docker engine is not running
  if ! docker info >/dev/null 2>&1; then
    echo "Starting OrbStack..."
    open -a OrbStack

    # Wait for Docker to become available
    local attempts=0
    until docker info >/dev/null 2>&1; do
      attempts=$((attempts + 1))

      if (( attempts >= 30 )); then
        echo "Docker did not become available."
        return 1
      fi

      sleep 1
    done
  fi

  # Last, start the existing container, or create it if it does not exist
  if docker container inspect "$container_name" >/dev/null 2>&1; then
    if [ "$(docker inspect -f '{{.State.Running}}' "$container_name")" != "true" ]; then
      echo "Starting Excalidraw..."
      docker start "$container_name" >/dev/null
    else
      echo "Excalidraw is already running."
    fi
  else
    echo "Creating Excalidraw container..."
    docker run -d \
      --name "$container_name" \
      -p 3000:80 \
      --restart unless-stopped \
      "$image_name" >/dev/null
  fi

  echo "Opening $url"
  open "$url"
}

# Initialize zoxide last
eval "$(zoxide init zsh)"