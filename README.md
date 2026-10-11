# Dotfiles

Shared **Zsh + Starship** development environment for Arch Linux (including WSL2), Ubuntu (including Codespaces), Kali Linux, and macOS.

Zsh uses Swedish regional formats (`sv_SE.UTF-8`) and English command messages (`LC_MESSAGES=C`). An inherited `LC_ALL` is cleared so it cannot override these choices. The Swedish UTF-8 locale must be available on the system; check with `locale -a`. Keyboard layout is configured separately in the operating system.

## Structure

```text
.dotfiles/
├── install.sh
├── installers/
│   ├── arch.sh
│   ├── ubuntu.sh
│   ├── kali.sh
│   ├── macos.sh
│   ├── developer-tools.sh
│   ├── options.sh
│   ├── debian.sh
│   └── common.sh
├── zsh/
│   ├── .zshrc
│   ├── .zsh_aliases
│   └── .git.scmbrc
├── git/
│   └── .gitconfig
├── vim/
│   ├── .vimrc
│   └── colors/oxocarbon.vim
└── starship/
    └── starship.toml
```

## Install

Install Git first, plus Homebrew on macOS (https://brew.sh). Then:

```bash
git clone https://github.com/wllmr/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash install.sh
```

The entry point detects the OS and invokes the matching installer. All platforms receive Zsh, zsh-completions, autosuggestions, syntax highlighting, GitHub CLI, SCM Breeze, fzf, Starship, eza, bat, zoxide, ripgrep, fd, jq, Mike Farah's yq v4, wget, Git, Vim, Ruby, curl, plus Rust (rustup, Cargo and stable rustc) where available.

- Arch: `pacman` (`go-yq` supplies Mike Farah's yq).
- Kali: `apt` for ripgrep/jq and optional fd-find; the official Go yq binary installs into `~/.local/bin`.
- Ubuntu: `apt` for ripgrep/jq and optional fd-find; the official Go yq binary installs into `~/.local/bin`. Optional tools unavailable in the configured repositories produce warnings. Starship uses the official installer as a fallback.
- macOS: `brew` (including `yq`). Homebrew must already be installed.

Common setup symlinks `~/.zshrc`, `~/.zsh_aliases`, `~/.vimrc`, `~/.vim/colors/oxocarbon.vim` and `~/.config/starship.toml`, backing up existing files before replacing them. Git configuration is copied once into `~/.gitconfig` rather than symlinked so `gh auth setup-git` and `git config --global` do not modify tracked repository files. An existing regular Git config is retained; a prior symlink is replaced with an independent copy preserving its effective contents. It installs SCM Breeze if missing. Rust is installed through the official rustup installer and managed consistently across all four OSes; Linux installs build tools for linking. The OS script sets Zsh as the non-root user's default login shell.

The installer can be rerun without duplicating symlinks. SCM Breeze may prompt during its initial installation. Changing the default shell can request your password/sudo access.

## Optional developer tools

After base packages are installed, an `fzf` multi-select menu lets you select Docker, Codex CLI, Claude Code, Herdr, and Node.js (nvm) independently with **Tab** and confirm with **Enter** (or **Esc** to skip). None are installed by default in non-interactive sessions.

```bash
./install.sh --with-codex --with-claude
./install.sh --with-docker --with-codex
./install.sh --with-herdr
./install.sh --with-node --node-version=22
./install.sh --with-codex --node-version=24
```

**Node.js:** installed through nvm. Selecting Node or Codex prompts for the desired Node.js version (for example `22`, `24`, `22.14.0`, or `lts/*`); pressing Enter selects the latest LTS. The installed version is set as the **nvm default** for future shell sessions. When running non-interactively, use `--node-version=VERSION` (which also enables Node installation). Zsh loads nvm automatically. Selecting Codex installs Node.js first if needed.

The setup bootstraps nvm without automatically installing Node, then loads it without activating a previous default. It explicitly installs/selects the requested Node version and replaces the saved default. Already-installed packages are safe to reuse; genuine installation errors still stop the script.

Installation and Zsh startup reset inherited nvm PATH entries through `nvm deactivate` before selecting Node. This prevents older nvm versions from leaving Homebrew's Node ahead of the selected nvm version. Homebrew Node does not need to be uninstalled. New Zsh sessions activate the saved nvm default.

**Package managers:** npm comes with Node.js automatically. After selecting a Node version, a second fzf multi-select lets you additionally install **pnpm**, **Yarn**, and/or **Bun**. You can choose more than one. pnpm and Yarn use Corepack (installed separately if Node does not bundle it), allowing projects to pin their package manager versions. Bun is installed using the supported npm package into the chosen nvm Node installation.

For unattended installs, use `--with-pnpm`, `--with-yarn`, or `--with-bun` (each also selects Node.js). For example:

```bash
./install.sh --node-version=24 --with-pnpm --with-yarn
```

Flags are processed in order. `--no-node` clears previously selected pnpm, Yarn and Bun; a later `--with-pnpm`, `--with-yarn` or `--with-bun` enables Node again. Codex always requires Node, even with `--no-node`.

**Codex:** installed into the user-local `~/.local` npm prefix from `@openai/codex` (npm is provided by the selected nvm Node.js installation).

**Herdr:** installed independently of Node.js through the official `https://herdr.dev/install.sh` installer on Linux and macOS. Select it in the interactive menu or run `./install.sh --with-herdr` (use `--no-herdr` to disable). Existing installations are skipped. Run `herdr` to launch it. Review the upstream installation script before use in a restricted environment.

**Claude Code:** installed with Anthropic's native `https://claude.ai/install.sh` installer. This is an optional external installer; review the source before running it in a security-restricted environment.

Neither installation stores credentials in this repository. Authenticate manually by running `codex` or `claude` after installation.

## Vim theme

The Oxocarbon reference theme targets Neovim only. This repository includes a native Vim colorscheme based on the official [Oxocarbon Base16 dark palette](https://github.com/nyoom-engineering/base16-oxocarbon), so the existing `vim` command works without Neovim or a plugin manager. Open Vim and run `:colorscheme` to verify `oxocarbon` is active. This is a Vim-compatible adaptation, not the original Neovim renderer.

## CLI tools

SCM Breeze is the sole Git-alias provider; its upstream defaults are enabled on every platform. `gpl` pulls, `gps` pushes, `gl` shows formatted Git history, `gs` shows numbered status, and `ga` stages numbered files. `gca` is SCM Breeze's stage-and-commit-all helper, `gcm` amends a commit, and `gap` stages changes interactively. Starship remains the prompt; the Oh My Zsh Git plugin is neither installed nor loaded.

The only custom Git shortcut is `gpsup`, a function running `git push --set-upstream origin HEAD` to push the current branch and establish its upstream. Additional Git push arguments are forwarded, for example `gpsup --dry-run`. It requires an `origin` remote and a checked-out branch. Use `gps` for ordinary pushes; there is no managed `gp` or `gcall` alias.

The installer manages `~/.git.scmbrc` and preserves existing SCM Breeze preferences in `~/.git.scmbrc.local`, with a backup of the original file. Put personal SCM Breeze settings in the local file; these can override upstream alias names, but standard aliases remain enabled. Run `bash install.sh` and then `exec zsh` on each machine to activate the shared command set. Start a fresh shell rather than merely sourcing `.zshrc`, so old Git-plugin aliases do not remain in memory. Previously downloaded Oh My Zsh files may remain on disk, but are unused.

### Repository jumping and completion

Interactive installation asks for the existing directory containing your repositories, then builds SCM Breeze's native index. Use Tab to complete paths (for example `~/Doc`); press Tab again to list ambiguous matches. Native Bash filename completion shows both files and folders, but the installer accepts only existing directories. Names containing spaces are supported. Press Enter to retain a valid current directory, or to skip when none is configured. For unattended setup, provide the directory explicitly:

```bash
bash install.sh --repo-dir="$HOME/Documents"
```

The selected path is saved as plain text in `~/.config/dotfiles/scm-repo-dir`, separate from personal SCM Breeze preferences, and takes precedence over their `GIT_REPO_DIR`. Non-interactive runs without `--repo-dir` leave the setting unchanged and do not rebuild the index. Invalid directories are rejected without replacing the saved path.

In a fresh shell, `c` goes to the selected root, `c project` jumps to a matching repository, and `c --rebuild` refreshes the index after adding projects. No Autojump installation is needed. Zoxide's `z`/`zi` remain available for general directory navigation.

Zsh explicitly expands aliases for completion (`NO_COMPLETE_ALIASES`), and the custom `gpsup` function uses Git push completion. Completion still requires successful `compinit`; if it reports insecure Homebrew directories, inspect them with `compaudit` and fix their ownership/permissions rather than bypassing the security check.

`rg` searches files, `fd` finds files, `jq` processes JSON, and `yq` v4 processes YAML. On Ubuntu/Kali, the `fd-find` executable is often named `fdfind`; shared setup links `~/.local/bin/fd` to that executable. The Go-based `yq` is used consistently instead of the differently implemented Debian `yq` package. If optional packages are unavailable, installation logs a warning.

## Optional Docker (no Docker Desktop)

Run `./install.sh` interactively and select Docker in the `fzf` menu, or specify `./install.sh --with-docker`. Docker is off by default for non-interactive installs (or use `--no-docker`).

- **Arch Linux / native Linux**: installs `docker` and Compose packages. The local daemon is not automatically enabled or started. On a systemd installation, use `sudo systemctl enable --now docker` when you want to enable it.
- **Ubuntu / Kali**: installs `docker.io` and `docker-compose-v2` when available in configured apt repositories. On native Linux with systemd, use `sudo systemctl enable --now docker` if the daemon is not running.
- **WSL2**: Docker Desktop is **not required or used**. Run a Linux Docker Engine inside your WSL distribution. WSL systemd must be enabled for `systemctl` commands to work: add `[boot]` followed by `systemd=true` to `/etc/wsl.conf`, restart the distro with `wsl --shutdown` from Windows PowerShell, then `sudo systemctl enable --now docker`. Check `ps -p 1 -o comm=` to verify systemd. WSL daemon operation also depends on kernel capabilities/network configuration.
- **macOS**: installs `docker`, `docker-compose`, and **Colima**, a Docker-compatible VM backend. Start it with `colima start`; stop it with `colima stop`. No Docker Desktop installation is involved.

The installer does **not** add your account to the `docker` group or automatically start a daemon. Membership of the Linux `docker` group permits root-equivalent access to the host, so use `sudo docker ...` or explicitly configure permissions after reviewing the risk.

`wget` is always installed on all four platforms.

## Verify

Run regression checks without installing packages or changing personal configuration:

```bash
bash tests/setup.sh
zsh -f tests/shell.zsh
bash tests/git-tools.sh
bash tests/node-path.sh
bash tests/repository-prompt.sh
```

The Git integration test uses the complete installed SCM Breeze implementation in an isolated home directory; if SCM Breeze is absent, that part reports a skip. It tests `gpsup` against a temporary local bare repository, without pushing to an external remote. No plugin downloads are needed. Linux package-manager calls are simulated in the offline tests; a full Linux installation still needs verification on Linux.

The offline Node PATH test uses installed nvm and Node 24 in an isolated home with a competing system-Node fixture. It checks installation and managed Zsh startup; if nvm or Node 24 is absent, it reports a skip.

The repository-prompt test uses a real terminal to check Tab completion, folder listing, names with spaces, and blank input. It reports a skip if `expect` or SCM Breeze is absent; neither is downloaded by the test.

For real nvm/Node integration, run the opt-in network test. It downloads nvm and Node 24 into a temporary home, checks fresh installation, stale-default recovery, reruns, and activation in a new Bash process, then removes the temporary installation. It does not change your installed Node versions or personal settings:

```bash
RUN_NODE_INTEGRATION=1 bash tests/node-tools.sh
```

```bash
zsh --version
starship --version
gh --version
fzf --version
wget --version
rustc --version
cargo --version
rg --version
fd --version
jq --version
yq --version
# When Docker is selected and an engine is running:
docker --version
docker compose version
docker info
# If the optional AI tools were installed:
codex --version
claude --version
herdr --version # if selected
node --version
npm --version
nvm alias default
pnpm --version # if selected
yarn --version # if selected
bun --version # if selected
```

Authenticate separately with `gh auth login`. Never commit credentials or SSH private keys. Starship is the only prompt; Oh My Zsh and Powerlevel10k are not loaded.

For WSL, terminate and reopen your distribution from Windows PowerShell after installation. For terminal glyphs, use a Nerd Font in your terminal settings.

## Update

```bash
cd ~/.dotfiles
git pull --ff-only
bash install.sh
```
