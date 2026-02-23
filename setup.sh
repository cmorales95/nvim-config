#!/bin/bash
#
# Neovim config setup script
# Installs all prerequisites for this nvim configuration
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is designed for macOS. For other systems, install dependencies manually."
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    error "Homebrew is not installed. Install it from https://brew.sh"
    exit 1
fi

info "Starting Neovim config setup..."

# =============================================================================
# Homebrew packages
# =============================================================================
info "Installing Homebrew packages..."

BREW_PACKAGES=(
    "neovim"
    "lazygit"
    "ripgrep"
    "imagemagick"
    "luarocks"
    "fd"
)

for pkg in "${BREW_PACKAGES[@]}"; do
    if brew list "$pkg" &> /dev/null; then
        info "$pkg is already installed"
    else
        info "Installing $pkg..."
        brew install "$pkg"
    fi
done

# =============================================================================
# Lua dependencies (for image.nvim)
# =============================================================================
info "Installing Lua dependencies..."

if luarocks --lua-version 5.1 list | grep -q "magick"; then
    info "magick rock is already installed"
else
    info "Installing magick rock..."
    luarocks --lua-version 5.1 install magick
fi

# =============================================================================
# Python virtual environment for Neovim
# =============================================================================
info "Setting up Python virtual environment for Neovim..."

NVIM_VENV="$HOME/.venvs/nvim"

# Check if uv is available, otherwise use python3 -m venv
if command -v uv &> /dev/null; then
    if [[ -d "$NVIM_VENV" ]]; then
        info "Python venv already exists at $NVIM_VENV"
    else
        info "Creating Python venv with uv..."
        uv venv "$NVIM_VENV" --python 3.12
    fi
    info "Installing Python packages..."
    uv pip install --python "$NVIM_VENV/bin/python" pynvim jupyter_client ipykernel cairosvg pnglatex plotly kaleido pyperclip nbformat
else
    warn "uv not found, using python3 -m venv instead"
    if [[ -d "$NVIM_VENV" ]]; then
        info "Python venv already exists at $NVIM_VENV"
    else
        info "Creating Python venv..."
        python3 -m venv "$NVIM_VENV"
    fi
    info "Installing Python packages..."
    "$NVIM_VENV/bin/pip" install --upgrade pip
    "$NVIM_VENV/bin/pip" install pynvim jupyter_client ipykernel cairosvg pnglatex plotly kaleido pyperclip nbformat
fi

# =============================================================================
# Nerd Font check
# =============================================================================
echo ""
warn "MANUAL STEP REQUIRED: Install a Nerd Font"
echo "  1. Download a Nerd Font from https://www.nerdfonts.com/font-downloads"
echo "     (Recommended: JetBrainsMono Nerd Font or FiraCode Nerd Font)"
echo "  2. Install the font on your system"
echo "  3. Set it as your terminal's font"
echo ""

# =============================================================================
# R language server (optional)
# =============================================================================
if command -v R &> /dev/null; then
    echo ""
    info "R is installed. To enable R LSP support, run this in R:"
    echo "  install.packages(\"languageserver\")"
    echo ""
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "==========================================="
info "Setup complete!"
echo "==========================================="
echo ""
echo "Next steps:"
echo "  1. Install a Nerd Font (see above)"
echo "  2. Open Neovim: nvim"
echo "  3. Wait for lazy.nvim to install plugins"
echo "  4. Run :Mason to verify LSP servers are installed"
echo ""
echo "For inline images (Jupyter): Use Kitty terminal"
echo ""
