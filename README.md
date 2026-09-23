# topgrade-config

My [topgrade](https://github.com/topgrade-rs/topgrade) setup to keep a Linux
machine up to date and clean with one command.

topgrade detects what is installed and updates it: distro packages, snap,
flatpak, firmware, rustup and cargo binaries, VS Code extensions, git repos in
`~/git/PUBLIC`, docker images and more. [`topgrade.toml`](topgrade.toml) adds
the rest as custom commands: Go toolchain, snap revisions, pip cache, locate database, journal
logs, old trash and thumbnails, a reboot check and manual backup reminders.

## Install on a fresh machine

1. Rust toolchain:

   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. Build dependencies (`cargo install` compiles from source: it needs a C
   linker, and cargo-update links against OpenSSL):

   ```bash
   sudo apt install build-essential pkg-config libssl-dev   # Debian/Ubuntu
   sudo dnf install gcc pkgconf openssl-devel               # Fedora
   sudo pacman -S --needed base-devel openssl               # Arch/Manjaro/CachyOS
   ```

3. topgrade, plus cargo-update so topgrade's `cargo` step keeps topgrade
   itself (and every other cargo binary) up to date:

   ```bash
   cargo install topgrade cargo-update
   ```

   Optional helpers that extend built-in steps:

   ```bash
   cargo install cargo-cache                    # lets `cleanup` trim cargo's download cache
   go install github.com/nao1215/gup@latest     # lets the `go` step update `go install` binaries
   ```

4. This repo:

   ```bash
   git clone https://github.com/gelanchez/topgrade-config.git ~/git/PROJECTS/topgrade-config
   ```

   The custom commands in `topgrade.toml` reference `scripts/` by this path;
   if you clone elsewhere, update the paths there.

5. Point topgrade at the config, pick one:

   - **Symlink** (recommended): plain `topgrade` uses this config, and the
     file stays tracked in the repo.

     ```bash
     ln -s ~/git/PROJECTS/topgrade-config/topgrade.toml ~/.config/topgrade.toml
     ```

   - **Alias**: keeps `~/.config` untouched; add to `~/.bashrc`.

     ```bash
     alias upkeep='topgrade --config ~/git/PROJECTS/topgrade-config/topgrade.toml'
     ```

## Usage

With the symlink (use `upkeep` instead of `topgrade` with the alias):

```bash
topgrade                                  # full run; asks for the sudo password once
topgrade --dry-run                        # show what would run
topgrade --only system                    # run only the OS package manager step
topgrade --disable containers git_repos   # run all steps except container images and git pulls
```

See `topgrade --help` for all options.

## Adding things

Built-in steps run only when their tool is installed, so a newly installed
tool is usually picked up without changes. `topgrade --dry-run --show-skipped`
lists every step and why it is skipped. For anything topgrade does not
support, add a line under `[commands]` in `topgrade.toml`, guarded with
`command -v <tool> >/dev/null || exit 0;` so it is skipped where the tool is
missing.
