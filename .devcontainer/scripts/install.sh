#!/usr/bin/env bash
set -euo pipefail

# ----------
# Settings
# ----------
NVM_VERSION="${NVM_VERSION:-v0.39.7}" # set via env to override
: "${CI:=false}"

# ----------
# Helpers
# ----------
have() { command -v "$1" >/dev/null 2>&1; }

detect_profile() {
  # Prefer explicit PROFILE if user set it
  if [[ -n "${PROFILE-}" ]]; then echo "$PROFILE"; return; fi
  if [[ -n "${ZSH_VERSION-}" ]] || [[ "${SHELL:-}" == *"/zsh" ]]; then
    echo "$HOME/.zshrc"
  elif [[ -f "$HOME/.bashrc" ]]; then
    echo "$HOME/.bashrc"
  elif [[ -f "$HOME/.bash_profile" ]]; then
    echo "$HOME/.bash_profile"
  else
    echo "$HOME/.profile"
  fi
}

append_once() {
  # append a block to profile if not already present
  local profile="$1" key="$2" block="$3"
  mkdir -p "$(dirname "$profile")"
  touch "$profile"
  if ! grep -q "$key" "$profile"; then
    {
      echo ""
      echo "# BEGIN $key"
      echo "$block"
      echo "# END $key"
    } >> "$profile"
  fi
}

ensure_path_now() {
  # export var=... and prepend to PATH for current shell
  # shellcheck disable=SC2163
  export "$1"
  export PATH="$2:$PATH"
}

msg()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m✓\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!\033[0m %s\n" "$*"; }
die()  { printf "\033[1;31m✗ %s\033[0m\n" "$*" >&2; exit 1; }

trap 'die "Error on line $LINENO"' ERR

PROFILE_FILE="$(detect_profile)"

# ----------
# Installers
# ----------
install_node() {
  if have node; then ok "Node.js already installed ($(node -v))"; return 0; fi

  msg "Installing Node.js (via nvm $NVM_VERSION)…"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  ok "Node.js $(node -v)"

  # Enable Corepack and activate latest Yarn/PNPM shims
  corepack enable || true
  ok "Corepack enabled"

  # Persist NVM + Corepack for future shells
  append_once "$PROFILE_FILE" "NVM_SETUP" \
'export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
command -v corepack >/dev/null 2>&1 && corepack enable >/dev/null 2>&1 || true'
}

install_pnpm() {
  if have pnpm; then ok "pnpm already installed ($(pnpm -v))"; return 0; fi
  if ! have corepack; then warn "Corepack not found; pnpm will be installed via npm -g"; fi

  if have corepack; then
    msg "Activating pnpm via Corepack…"
    corepack prepare pnpm@latest --activate
  else
    msg "Installing pnpm globally via npm…"
    npm install -g pnpm
  fi
  ok "pnpm $(pnpm -v)"
}

install_yarn() {
  if have yarn; then ok "yarn already installed ($(yarn -v))"; return 0; fi
  if have corepack; then
    msg "Activating Yarn via Corepack…"
    corepack prepare yarn@stable --activate
  else
    msg "Installing yarn globally via npm…"
    npm install -g yarn
  fi
  ok "yarn $(yarn -v)"
}

install_deno() {
  if have deno; then ok "Deno already installed ($(deno --version | head -n1))"; return 0; fi

  msg "Installing Deno…"
  curl -fsSL https://deno.land/x/install/install.sh | sh

  ensure_path_now "DENO_INSTALL=$HOME/.deno" "$HOME/.deno/bin"
  append_once "$PROFILE_FILE" "DENO_PATH" \
'export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"'
  ok "Deno $(deno --version | head -n1)"
}

install_bun() {
  if have bun; then ok "Bun already installed ($(bun -v))"; return 0; fi

  msg "Installing Bun…"
  curl -fsSL https://bun.sh/install | bash

  ensure_path_now "BUN_INSTALL=$HOME/.bun" "$HOME/.bun/bin"
  append_once "$PROFILE_FILE" "BUN_PATH" \
'export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"'
  ok "Bun $(bun -v)"
}

# ----------
# CLI
# ----------
usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --node          Install Node.js (nvm + LTS)
  --deno          Install Deno
  --bun           Install Bun
  --pnpm          Install pnpm (via Corepack if available)
  --yarn          Install Yarn (via Corepack if available)
  --all           Install everything (Node, Deno, Bun, pnpm, Yarn)
  -y, --yes       Non-interactive; assume --all
  -h, --help      Show this help

Environment:
  NVM_VERSION     Tag for nvm installer (default: $NVM_VERSION)
  PROFILE         Force profile file (default: auto-detected: $PROFILE_FILE)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then usage; exit 0; fi

if [[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]]; then
  set -- --all
fi

if [[ "$#" -eq 0 ]]; then
  echo "Choose your setup:"
  echo "  1) Node.js only"
  echo "  2) Deno only"
  echo "  3) Bun only"
  echo "  4) Everything: Node + Deno + Bun + pnpm + yarn"
  read -rp "Enter choice (1–4): " choice
  case "$choice" in
    1) set -- --node ;;
    2) set -- --deno ;;
    3) set -- --bun ;;
    4) set -- --all ;;
    *) die "Invalid choice." ;;
  esac
fi

DO_NODE=false DO_DENO=false DO_BUN=false DO_PNPM=false DO_YARN=false
for arg in "$@"; do
  case "$arg" in
    --node) DO_NODE=true ;;
    --deno) DO_DENO=true ;;
    --bun)  DO_BUN=true ;;
    --pnpm) DO_PNPM=true ;;
    --yarn) DO_YARN=true ;;
    --all)  DO_NODE=true; DO_DENO=true; DO_BUN=true; DO_PNPM=true; DO_YARN=true ;;
    *) die "Unknown option: $arg (see --help)";;
  esac
done

$DO_NODE && install_node
$DO_DENO && install_deno
$DO_BUN  && install_bun
$DO_PNPM && install_pnpm
$DO_YARN && install_yarn

echo
ok "Done."
echo "Profile: $PROFILE_FILE"
echo "Open a new terminal, or run:  source \"$PROFILE_FILE\""
