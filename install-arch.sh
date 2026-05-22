#!/usr/bin/env bash
# Bootstrap a fresh Arch Linux machine to match this setup exactly.
# Run as your normal user (not root). sudo will be called where needed.
# Usage: ./install-arch.sh

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
command -v pacman &>/dev/null || err "This script requires an Arch Linux system."
log "Running as $(whoami) on $(uname -n)"

# ── yay (AUR helper) ──────────────────────────────────────────
section "Yay (AUR helper)"
if ! command -v yay &>/dev/null; then
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
else
  log "yay already installed."
fi

# ── pacman packages ───────────────────────────────────────────
section "Pacman Packages"
sudo pacman -Syu --noconfirm

PACMAN_PACKAGES=(
  # Desktop — GNOME
  gnome-tweaks dconf-editor
  papirus-icon-theme ttf-font-awesome ttf-hack noto-fonts noto-fonts-emoji
  kitty alacritty redshift flameshot rofi dunst

  # Shell / terminal tools
  zsh zsh-autosuggestions zsh-syntax-highlighting
  fish tmux bat btop htop
  fd fzf ripgrep lsof nnn wl-clipboard
  traceroute openbsd-netcat cronie

  # Editors / dev
  neovim luarocks git make nodejs npm

  # Security — official repos
  nmap aircrack-ng hydra john sqlmap
  wireshark-qt ophcrack sqlitebrowser
  zathura zathura-pdf-mupdf bind

  # System
  flatpak open-vm-tools
  pipewire pipewire-pulse wireplumber pavucontrol
  curl wget unzip starship
)

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
log "Pacman packages installed."

# ── yay packages (AUR) ───────────────────────────────────────
section "AUR Packages (yay)"

YAY_PACKAGES=(
  # Fonts
  inter-font

  # Desktop
  gnome-shell-extension-manager

  # Shell
  grc

  # Security — AUR
  ffuf
  metasploit
  netexec
  responder
  starkiller
  dirbuster
  zenmap
  testssl
  autopsy
  guymager
  faraday
  legion
  gophish
  fern-wifi-cracker
  cutycapt
)

yay -S --needed --noconfirm "${YAY_PACKAGES[@]}" \
  || warn "Some AUR/BlackArch packages failed — install them manually with: yay -S <package>"

log "AUR/BlackArch packages done."

# ── flatpak — obsidian ────────────────────────────────────────
section "Flatpak — Obsidian"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub md.obsidian.Obsidian \
  || warn "Obsidian flatpak install failed — install manually."

# ── starship is already installed via pacman above ────────────

# ── oh-my-zsh ─────────────────────────────────────────────────
section "Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "Oh My Zsh already installed."
fi

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

# ── smuggler ──────────────────────────────────────────────────
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
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
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

link "$DOTFILES_DIR/.bashrc"    "$HOME/.bashrc"
link "$DOTFILES_DIR/.zshrc"     "$HOME/.zshrc"
link "$DOTFILES_DIR/.p10k.zsh"  "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/.dircolors" "$HOME/.dircolors"
link "$DOTFILES_DIR/.latexmkrc" "$HOME/.latexmkrc"

mkdir -p "$HOME/.tmux"
link "$DOTFILES_DIR/.tmux/pentest.sh"         "$HOME/.tmux/pentest.sh"
link "$DOTFILES_DIR/.tmux/session-manager.sh" "$HOME/.tmux/session-manager.sh"
chmod +x "$HOME/.tmux/pentest.sh" "$HOME/.tmux/session-manager.sh"

for dir in dunst kitty redshift rofi scripts zathura fish nvim; do
  link "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
done
link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# ── enable services ───────────────────────────────────────────
section "Services"
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null \
  && log "PipeWire services enabled." \
  || warn "PipeWire service enable failed — run manually after login."

sudo systemctl enable cronie 2>/dev/null && log "cronie enabled." || true
sudo systemctl enable vmtoolsd 2>/dev/null && log "vmtoolsd enabled." || true

# ── default shell → zsh ───────────────────────────────────────
section "Default shell"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" != "/usr/bin/zsh" ]; then
  chsh -s /usr/bin/zsh
  log "Default shell set to zsh (takes effect on next login)."
else
  log "zsh is already the default shell."
fi

# ── install tmux plugins ──────────────────────────────────────
section "Tmux plugins"
if command -v tmux &>/dev/null; then
  TMUX= "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null \
    && log "Tmux plugins installed." \
    || warn "TPM plugin install failed — open tmux and press prefix+I manually."
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
echo "   5. Install GNOME extensions from extensions.gnome.org (see README)"
echo "   6. Clone private repos (requires SSH key):"
echo "        git clone git@github.com:Galatron01/payload-manager ~/payload-manager"
echo "        git clone git@github.com:Galatron01/pentest-tmux ~/pentest-tmux"
echo ""
