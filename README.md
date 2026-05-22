# kali-setup

Dotfiles and bootstrap scripts for my Kali Linux setup. Clone and run the install script to replicate the full environment on a fresh machine.

## Install

**Kali:**
```bash
git clone git@github.com:Galatron01/kali-setup.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

**Arch:**
```bash
git clone git@github.com:Galatron01/kali-setup.git ~/dotfiles
cd ~/dotfiles && ./install-arch.sh
```

## What's included

- **DE:** GNOME (dark, Kali-Dark theme, Flat-Remix-Blue-Dark icons)
- **Terminal:** kitty + tmux (Dracula theme, custom pentest session launcher)
- **Shell:** zsh (Oh My Zsh + Powerlevel10k) + fish
- **Editor:** neovim (LazyVim)
- **Prompt:** starship
- **Tools:** nmap-dracula, smuggler
- **Pentest:** Full Kali toolset via metapackages + starkiller, faraday, gophish

## GNOME Extensions

- blur-my-shell
- dash-to-dock
- just-perfection
- space-bar
- tiling-assistant
- tophat
- runcat
- switcher
- system-monitor
- top-panel-vpnip (Kali)

## Structure

```
.
├── .bashrc / .zshrc / .p10k.zsh
├── .tmux.conf
├── .tmux/
│   ├── pentest.sh          # structured pentest session launcher
│   └── session-manager.sh  # fzf session switcher
├── .config/
│   ├── kitty/
│   ├── rofi/
│   ├── dunst/
│   ├── nvim/               # LazyVim
│   ├── fish/
│   └── starship.toml
├── install.sh              # Kali bootstrap
└── install-arch.sh         # Arch bootstrap
```

## After install

1. Log out and back in for zsh to take effect
2. Run `p10k configure` if prompt needs reconfiguring
3. Open nvim — `:Lazy` installs plugins automatically
4. Set up Obsidian vault
5. Install GNOME extensions from extensions.gnome.org
6. Clone private repos (needs SSH key):
   ```bash
   git clone git@github.com:Galatron01/payload-manager ~/payload-manager
   git clone git@github.com:Galatron01/pentest-tmux ~/pentest-tmux
   ```
