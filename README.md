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

## Tmux Pentest Session

> Just want the pentest tmux setup without installing everything else? Run:
> ```bash
> bash <(curl -fsSL https://raw.githubusercontent.com/Galatron01/kali-setup/main/install-pentest-tmux.sh)
> ```
> Works on Kali and Arch. Only requires tmux, fzf, and git.

Launch a structured pentest tmux session with:

```bash
~/.tmux/pentest.sh <client> <scope> <logins>
```

Or trigger it from inside tmux with **prefix + Ctrl-T** which opens an interactive popup.

**Arguments:**
- `client` — client/engagement name, used for the session name and folder (`~/Documents/Clients/<client>/`)
- `scope` — IP, domain, or path to a scope file. Use `f` to fuzzy-pick a file
- `logins` — credentials or notes to prepend to scope.txt (optional)

**Example:**
```bash
~/.tmux/pentest.sh acmecorp 192.168.1.0/24 "admin:password123"
```

**What gets created:**
- `~/Documents/Clients/<client>/scope.txt` — targets
- `~/Documents/Clients/<client>/notes.md` — pre-filled notes template
- `~/Documents/Clients/<client>/found/` — nmap output saved here
- `~/Documents/Clients/<client>/not found/`

**Windows:**

| Window | Purpose |
|--------|---------|
| `nmap` | Pre-loaded nmap command (edit flags then Enter). Output saves to `found/nmap.txt` |
| `ssl` | testssl / cert checks |
| `dir enum` | ffuf / gobuster / dirb |
| `scope` | nvim with scope.txt open |
| `js` | JS recon |
| `reco` | General recon |

**Session manager** — **prefix + Ctrl-P** opens a fuzzy session switcher. Type a new name and press Enter to create a session, Ctrl-D to delete.

---

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
