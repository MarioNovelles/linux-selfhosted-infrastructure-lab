# Install Neovim AppImage and LazyVim

This guide installs a modern Neovim setup on the Ubuntu Server VM used in this homelab.

Ubuntu’s `apt` version of Neovim can be older than what LazyVim requires, so I use the official Neovim AppImage instead.

## 1. Install Dependencies

```bash
sudo apt update

sudo apt install -y \
  git \
  curl \
  wget \
  unzip \
  tar \
  gzip \
  gcc \
  ripgrep \
  fd-find \
  fzf \
  python3 \
  python3-pip \
  npm
```

Why these packages are installed:

| Package                  | Purpose                           |
| ------------------------ | --------------------------------- |
| `git`                    | Required for LazyVim and plugins  |
| `curl` / `wget`          | Download files from the terminal  |
| `unzip`, `tar`, `gzip`   | Extract archives                  |
| `gcc`                    | C compiler required by Treesitter |
| `ripgrep`                | Fast text search                  |
| `fd-find`                | Fast file search                  |
| `fzf`                    | Fuzzy finder                      |
| `python3`, `python3-pip` | Python support                    |
| `npm`                    | Used to install `tree-sitter-cli` |

I install `gcc` instead of the full `build-essential` package to keep the VM minimal.

If a future plugin or language workflow needs `make`, `g++`, or other build tools, they can be installed later with:

```bash
sudo apt install -y build-essential
```

## 2. Fix the `fd` Command on Ubuntu

Ubuntu installs `fd` as `fdfind`, but Neovim tools usually expect the command to be called `fd`.

```bash
mkdir -p ~/.local/bin
ln -sf "$(command -v fdfind)" ~/.local/bin/fd
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
fd --version
rg --version
fzf --version
gcc --version
```

## 3. Install tree-sitter-cli

LazyVim uses Treesitter for syntax parsing.

```bash
sudo npm install -g tree-sitter-cli
```

Verify:

```bash
tree-sitter --version
```

## 4. Download Neovim AppImage

```bash
cd /tmp

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage

chmod u+x nvim-linux-x86_64.appimage
```

Test it:

```bash
./nvim-linux-x86_64.appimage --version
```

The output should show a modern Neovim version.

## 5. Install Neovim Globally

Move the AppImage into `/opt/nvim` (for this to work you have to be on /tmp):

```bash
sudo mkdir -p /opt/nvim
sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim
```

Expose it globally as the `nvim` command:

```bash
sudo ln -sf /opt/nvim/nvim /usr/local/bin/nvim
```

Verify:

```bash
which nvim
nvim --version
```

Expected path:

```text
/usr/local/bin/nvim
```

Check that Neovim was built with LuaJIT:

```bash
nvim --version | grep -i luajit
```

## 6. Back Up Existing Neovim Files

Before installing LazyVim, back up any old Neovim config:

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null || true
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null || true
```

## 7. Install LazyVim

Clone the LazyVim starter configuration:

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
```

Remove the starter repo’s Git history:

```bash
rm -rf ~/.config/nvim/.git
```

## 10. Start Neovim

```bash
nvim
```

LazyVim will install its plugins on the first launch.

After it finishes, run these inside Neovim:

```vim
:LazyHealth
```

```vim
:checkhealth
```

## 11. Optional: Install lazygit

`lazygit` is optional, but useful for Git workflows inside LazyVim.

On newer Ubuntu versions, this may work:

```bash
sudo apt install -y lazygit
```

If the package is not available, skip it for now. LazyVim still works without it.

## 12. Nerd Font Note

LazyVim icons look best with a Nerd Font.

Install the Nerd Font on the computer you SSH from, not necessarily on the server.

Good options:

```text
JetBrainsMono Nerd Font
FiraCode Nerd Font
Hack Nerd Font
MesloLGS Nerd Font
```

Without a Nerd Font, LazyVim still works, but some icons may appear as squares or missing symbols.

## 13. Update Neovim Later (or use my update script in the scripts folder)

To update the Neovim AppImage:

```bash
cd /tmp

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage

chmod u+x nvim-linux-x86_64.appimage

sudo mv nvim-linux-x86_64.appimage /opt/nvim/nvim

nvim --version
```

## 14. Update LazyVim Plugins Later (or the update script)

Open Neovim:

```bash
nvim
```

Then run:

```vim
:Lazy update
```

## Final Result

The Ubuntu VM now has:

```text
Modern Neovim installed from AppImage
LazyVim installed under ~/.config/nvim
nvim available globally from /usr/local/bin/nvim
Treesitter, ripgrep, fd, fzf, Git, curl, npm, and gcc installed
```

This gives the VM a modern terminal editor for managing Docker Compose files, environment files, scripts, and infrastructure documentation.

