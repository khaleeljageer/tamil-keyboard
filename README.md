# Tamil Keyboard

A Debian package that makes it easy to enable Tamil input methods on
Debian and Ubuntu systems.

## What this is (and isn't)

The Tamil 99 and Tamil Phonetic layouts are **already on your system** —
they ship with `ibus-m17n`, which is in Debian and Ubuntu main. The hard
part is not installing them, it's knowing which input source to add.

This package provides `tamil-keyboard-setup`, a small command that adds
either layout to your desktop input sources for you.

If you would rather not install anything, you can do the same thing by
hand:

```bash
sudo apt install ibus ibus-m17n
gsettings set org.gnome.desktop.input-sources sources \
  "[('xkb', 'us'), ('ibus', 'm17n:ta:tamil99')]"
```

## Installation

### From the APT repository

```bash
# Add the repository
echo "deb https://khaleeljageer.github.io/tamil-keyboard stable main" \
  | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

# Add the signing key
wget -qO - https://khaleeljageer.github.io/tamil-keyboard/public-key.asc \
  | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tamil-keyboard.gpg

sudo apt update
sudo apt install tamil-keyboard
```

### From a local build

```bash
./build-packages.sh
sudo apt install ../tamil-keyboard_*.deb
```

## Usage

Run it as your **normal user**, not with `sudo` — it configures the
session it is run from.

```bash
# Add the Tamil 99 layout
tamil-keyboard-setup tamil99

# Or the phonetic layout
tamil-keyboard-setup phonetic

# See what you currently have
tamil-keyboard-setup --list

# Change your mind
tamil-keyboard-setup --remove tamil99
```

Switch between input sources with **Super+Space**.

The layout is added alongside whatever you already had; your existing
input sources are left untouched. Running the command twice is harmless.

See `man tamil-keyboard-setup` for the full reference.

## Requirements

- IBus as your input method framework (`ibus`, `ibus-m17n` — both pulled
  in automatically)
- A desktop that uses the GNOME `org.gnome.desktop.input-sources` schema

Both **Wayland and X11** are supported. If you are on a desktop that does
not use GNOME input sources (KDE, XFCE, and others), the command will say
so and you can configure IBus directly with `ibus-setup`.

If the layout does not show up after adding it, IBus may not be running:

```bash
ibus-daemon -drx
```

Logging out and back in achieves the same thing.

## Building

```bash
sudo apt-get install devscripts build-essential debhelper
./verify-package.sh    # sanity-check the packaging
./build-packages.sh    # produces ../tamil-keyboard_*.deb
```

## Repository layout

- `tamil-keyboard/bin/` — the `tamil-keyboard-setup` script
- `tamil-keyboard/debian/` — packaging metadata
- `.github/workflows/` — builds the package and publishes the APT
  repository to GitHub Pages on tagged releases

See `GITHUB-PAGES-APT-REPO.md` and `REPOSITORY-SETUP.md` for repository
hosting details.

## License

GPL-3.0+
