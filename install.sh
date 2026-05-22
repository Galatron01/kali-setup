#!/usr/bin/env bash
# Bootstrap a fresh Kali Linux machine to match this setup exactly.
# Run as your normal user (not root). sudo will be called where needed.
# Usage: ./install.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── colours ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()     { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
err()     { echo -e "${RED}[-]${NC} $*"; exit 1; }
section() { echo -e "\n${BLUE}══════════════════════════════════════${NC}\n${BLUE}  $*${NC}\n${BLUE}══════════════════════════════════════${NC}"; }

# ── pre-flight ────────────────────────────────────────────────
section "Pre-flight"
[ "$EUID" -eq 0 ] && err "Do not run as root — run as your normal user."
log "Running as $(whoami) on $(uname -n)"
command -v apt &>/dev/null || err "This script requires a Debian/Kali system."

# ── apt packages ──────────────────────────────────────────────
section "APT Packages"
sudo apt update -qq

APT_PACKAGES=(
  # Kali metapackages — full toolset
  kali-linux-default
  kali-tools-top10
  kali-tools-web
  kali-tools-passwords
  kali-tools-wireless
  kali-tools-forensics
  kali-tools-exploitation
  kali-tools-information-gathering
  kali-tools-post-exploitation
  kali-tools-sniffing-spoofing
  kali-tools-social-engineering

  # Desktop — GNOME
  gnome-tweaks gnome-shell-extension-manager dconf-editor
  papirus-icon-theme fonts-font-awesome fonts-hack fonts-inter fonts-noto-color-emoji
  kitty alacritty redshift flameshot

  # Shell / terminal tools
  zsh zsh-autosuggestions zsh-syntax-highlighting
  fish tmux bat btop htop
  fd-find fzf ripgrep grc lsof nnn wl-clipboard
  traceroute netcat-traditional cron

  # Editors / dev
  neovim luarocks git make nodejs npm

  # Extras not covered by metapackages
  starkiller faraday gophish cutycapt
  sqlitebrowser zathura

  # System
  flatpak open-vm-tools open-vm-tools-desktop
  pipewire pavucontrol curl wget unzip
)

sudo apt install -y "${APT_PACKAGES[@]}"
log "APT packages installed."

# ── flatpak — obsidian ────────────────────────────────────────
section "Flatpak — Obsidian"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub md.obsidian.Obsidian || warn "Obsidian flatpak install failed — install manually."

# ── starship prompt ───────────────────────────────────────────
section "Starship"
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  log "Starship already installed at $(command -v starship)"
fi

# ── oh-my-zsh ─────────────────────────────────────────────────
section "Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "Oh My Zsh already installed."
fi

# powerlevel10k theme
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  log "Powerlevel10k already installed."
fi

# ── nerd fonts ────────────────────────────────────────────────
section "Nerd Fonts (JetBrainsMono + FiraCode)"
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"

install_nerd_font() {
  local name="$1"
  local dest="$FONTS_DIR/$name"
  if [ -d "$dest" ] && [ "$(ls -A "$dest")" ]; then
    log "$name fonts already installed."
    return
  fi
  mkdir -p "$dest"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${name}.tar.xz"
  log "Downloading $name Nerd Font…"
  curl -fsSL "$url" | tar -xJ -C "$dest" 2>/dev/null \
    || warn "Failed to download $name — install manually from https://www.nerdfonts.com/font-downloads"
}

install_nerd_font "JetBrainsMono"
install_nerd_font "FiraCode"
fc-cache -f "$FONTS_DIR"
log "Fonts cached."

# ── nmap-dracula ──────────────────────────────────────────────
section "nmap-dracula"
if [ ! -d "$HOME/nmap-dracula" ]; then
  git clone https://github.com/kurealnum/nmap-dracula "$HOME/nmap-dracula"
else
  log "nmap-dracula already cloned."
fi

# ── smuggler (HTTP request smuggling) ────────────────────────
section "Smuggler"
if [ ! -d "$HOME/smuggler" ]; then
  git clone https://github.com/defparam/smuggler "$HOME/smuggler"
  python3 -m venv "$HOME/smuggler/venv"
  "$HOME/smuggler/venv/bin/pip" install -q -r "$HOME/smuggler/requirements.txt" 2>/dev/null \
    || warn "smuggler pip deps failed — run manually: cd ~/smuggler && pip install -r requirements.txt"
else
  log "smuggler already cloned."
fi

# ── tmux plugin manager ───────────────────────────────────────
section "Tmux Plugin Manager (TPM)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  log "TPM already installed."
fi

# ── dotfiles symlinks ─────────────────────────────────────────
section "Dotfiles symlinks"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up existing $dst → $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  log "  $dst → $src"
}

# home dotfiles
link "$DOTFILES_DIR/.bashrc"    "$HOME/.bashrc"
link "$DOTFILES_DIR/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES_DIR/.p10k.zsh"  "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/.dircolors" "$HOME/.dircolors"
link "$DOTFILES_DIR/.latexmkrc" "$HOME/.latexmkrc"

# tmux scripts
mkdir -p "$HOME/.tmux"
link "$DOTFILES_DIR/.tmux/pentest.sh"         "$HOME/.tmux/pentest.sh"
link "$DOTFILES_DIR/.tmux/session-manager.sh" "$HOME/.tmux/session-manager.sh"
chmod +x "$HOME/.tmux/pentest.sh" "$HOME/.tmux/session-manager.sh"

# ~/.config entries
for dir in dunst kitty redshift rofi scripts zathura fish nvim; do
  link "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
done
link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# ── default shell → zsh ───────────────────────────────────────
section "Default shell"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" != "/usr/bin/zsh" ]; then
  chsh -s /usr/bin/zsh
  log "Default shell set to zsh (takes effect on next login)."
else
  log "zsh is already the default shell."
fi

# ── install tmux plugins via tpm ─────────────────────────────
section "Tmux plugins"
if command -v tmux &>/dev/null; then
  TMUX= "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null \
    && log "Tmux plugins installed." \
    || warn "TPM plugin install failed — open tmux and press prefix+I to install manually."
fi

# ── done ──────────────────────────────────────────────────────
section "Done"
echo ""
log "Installation complete!"
echo ""
warn "Manual steps remaining:"
echo "   1. Log out and back in for the zsh shell change to take effect"
echo "   2. Run 'p10k configure' if the prompt needs reconfiguring"
echo "   3. Open nvim — :Lazy will auto-install plugins on first launch"
echo "   4. Set up your Obsidian vault"
echo "   5. On i3 startup, launch polybar with: ~/.config/polybar/launch.sh --<theme>"
echo "   6. Clone private repos (requires SSH key or PAT):"
echo "        git clone git@github.com:Galatron01/payload-manager ~/payload-manager"
echo "        git clone git@github.com:Galatron01/pentest-tmux ~/pentest-tmux"
echo ""
