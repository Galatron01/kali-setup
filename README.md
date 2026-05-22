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

- **WM:** i3 + polybar (12 themes) + picom + rofi + dunst
- **Terminal:** kitty + tmux (Dracula theme, custom pentest session launcher)
- **Shell:** zsh (Oh My Zsh + Powerlevel10k) + fish
- **Editor:** neovim (LazyVim)
- **Tools:** nmap-dracula, smuggler, starship prompt
- **Pentest:** Full Kali toolset via metapackages + starkiller, faraday, gophish

## Structure

```
.
├── .bashrc / .zshrc / .p10k.zsh
├── .tmux.conf
├── .tmux/
│   ├── pentest.sh          # structured pentest session launcher
│   └── session-manager.sh  # fzf session switcher
├── .config/
│   ├── i3/
│   ├── polybar/            # 12 themes
│   ├── kitty/
│   ├── rofi/
│   ├── dunst/
│   ├── picom/
│   ├── nvim/               # LazyVim
│   ├── fish/
│   └── starship.toml
├── install.sh              # Kali bootstrap
└── install-arch.sh         # Arch bootstrap
```

## Manual steps after install

1. Log out and back in for zsh to take effect
2. Run `p10k configure` if prompt needs reconfiguring
3. Open nvim — `:Lazy` installs plugins automatically
4. Set up Obsidian vault
5. Launch polybar: `~/.config/polybar/launch.sh --<theme>`
6. Clone private repos (needs SSH key):
   ```bash
   git clone git@github.com:Galatron01/payload-manager ~/payload-manager
   git clone git@github.com:Galatron01/pentest-tmux ~/pentest-tmux
   ```
