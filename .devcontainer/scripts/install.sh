#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# URLs for installers
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh"
DENO_INSTALL_URL="https://deno.land/install.sh"
BUN_INSTALL_URL="https://bun.sh/install"

# Trap for handling errors
trap 'echo -e "${RED}[ERROR] Something went wrong. Exiting.${NC}" && exit 1' ERR

# Helper functions for output
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Install Node.js using NVM
install_node() {
  warning "Installing Node.js with NVM..."
  export NVM_DIR="$HOME/.nvm"

  if [ ! -d "$NVM_DIR" ]; then
    curl -o- "$NVM_INSTALL_URL" | bash
    . "$NVM_DIR/nvm.sh"
    . "$NVM_DIR/bash_completion"
  else
    warning "NVM is already installed. Skipping reinstallation."
    . "$NVM_DIR/nvm.sh"
  fi

  # Install and configure Node.js
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*

  if command -v node &>/dev/null; then
    success "Node.js $(node -v) installed successfully!"
  else
    error "Node.js installation failed."
  fi
}

# Install Deno
install_deno() {
  if command -v deno &>/dev/null; then
    warning "Deno is already installed. Skipping installation."
    return
  fi

  warning "Installing Deno..."
  curl -fsSL "$DENO_INSTALL_URL" | sh

  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"

  if command -v deno &>/dev/null; then
    success "Deno $(deno --version | head -n 1) installed successfully!"
  else
    error "Deno installation failed."
  fi
}

# Install Bun
install_bun() {
  if command -v bun &>/dev/null; then
    warning "Bun is already installed. Skipping installation."
    return
  fi

  warning "Installing Bun..."
  curl -fsSL "$BUN_INSTALL_URL" | bash

  export PATH="$HOME/.bun/bin:$PATH"

  if command -v bun &>/dev/null; then
    success "Bun $(bun --version) installed successfully!"
  else
    error "Bun installation failed."
  fi
}

# Function to display the menu
show_menu() {
  echo -e "${YELLOW}Select the tools you want to install:${NC}"
  echo "1. Install Node.js"
  echo "2. Install Deno"
  echo "3. Install Bun"
  echo "4. Install All"
  echo "5. Install TypeScript"
  echo "6. Exit"
  read -p "Enter your choice (1-6): " choice
}
# Install TypeScript
install_typescript() {
  if command -v tsc &>/dev/null; then
    warning "TypeScript is already installed. Skipping installation."
    return
  fi

  warning "Installing TypeScript..."
  npm install -g typescript

  if command -v tsc &>/dev/null; then
    success "TypeScript $(tsc --version) installed successfully!"
  else
    error "TypeScript installation failed."
  fi
}

# Function to select a package manager
select_package_manager() {
  echo -e "${YELLOW}Select a package manager to install:${NC}"
  echo "1. npm (default with Node.js)"
  echo "2. yarn"
  echo "3. pnpm"
  echo "4. Skip"
  read -p "Enter your choice (1-4): " pm_choice

  case $pm_choice in
  1)
    success "npm is already installed with Node.js."
    ;;
  2)
    warning "Installing Yarn..."
    npm install -g yarn
    if command -v yarn &>/dev/null; then
      success "Yarn $(yarn --version) installed successfully!"
    else
      error "Yarn installation failed."
    fi
    ;;
  3)
    warning "Installing pnpm..."
    npm install -g pnpm
    if command -v pnpm &>/dev/null; then
      success "pnpm $(pnpm --version) installed successfully!"
    else
      error "pnpm installation failed."
    fi
    ;;
  4)
    warning "Skipping package manager installation."
    ;;
  *)
    warning "Invalid choice. Skipping package manager installation."
    ;;
  esac
}
while true; do
  show_menu

  case $choice in
  1)
    install_node
    ;;
  2)
    install_deno
    ;;
  3)
    install_bun
    ;;
  4)
    install_node
    install_deno
    install_bun
    ;;
  5)
    install_typescript
    ;;
  6)
    success "Exiting setup. All done!"
    break
    ;;
  *)
    warning "Invalid choice. Please select a valid option."
    ;;
  esac

  # Confirm and continue
  read -p "Do you want to perform another action? (y/n): " continue_choice
  if [[ "$continue_choice" != "y" ]]; then
    break
  fi
done
# Add exports to bashrc (if not already present)
warning "Updating environment variables in ~/.bashrc..."
{
  echo 'export NVM_DIR="$HOME/.nvm"'
  echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
  echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"'
  echo 'export DENO_INSTALL="$HOME/.deno"'
  echo 'export PATH="$DENO_INSTALL/bin:$HOME/.bun/bin:$PATH"'
} >>~/.bashrc

# Reload bashrc
source ~/.bashrc
success "Setup completed! PATH and runtime tools are ready."

select_package_manager