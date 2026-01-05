# Tamil Keyboard Debian Packages

This repository contains Debian packages for Tamil keyboard layouts that can be installed via `apt install`.

## Packages

- **tamil-99-keyboard**: Tamil 99 keyboard layout for IBus
- **tamil-phonetic-keyboard**: Tamil Phonetic keyboard layout for IBus

## Prerequisites

To build these packages, you need:

```bash
sudo apt-get install devscripts build-essential debhelper
```

## Building the Packages

### Quick Build

Run the build script:

```bash
./build-packages.sh
```

This will create `.deb` files in the parent directory.

### Manual Build

Build each package individually:

```bash
# Build tamil-99-keyboard
cd tamil-99-keyboard
dpkg-buildpackage -b -us -uc
cd ..

# Build tamil-phonetic-keyboard
cd tamil-phonetic-keyboard
dpkg-buildpackage -b -us -uc
cd ..
```

## Installing the Packages

### Local Installation

After building, install the packages:

```bash
# Install tamil-99-keyboard
sudo dpkg -i tamil-99-keyboard_*.deb
sudo apt-get install -f  # Install dependencies if needed

# Install tamil-phonetic-keyboard
sudo dpkg -i tamil-phonetic-keyboard_*.deb
sudo apt-get install -f  # Install dependencies if needed
```

Or use apt directly:

```bash
sudo apt-get install ./tamil-99-keyboard_*.deb
sudo apt-get install ./tamil-phonetic-keyboard_*.deb
```

### From APT Repository (GitHub Pages)

Install directly from the GitHub Pages APT repository:

```bash
# Add repository
echo "deb https://khaleeljageer.github.io/tamil-keyboard stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

# Add GPG key
wget -qO - https://khaleeljageer.github.io/tamil-keyboard/public-key.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tamil-keyboard.gpg

# Update and install
sudo apt update
sudo apt install tamil-99-keyboard
sudo apt install tamil-phonetic-keyboard
```

### From Custom APT Repository

If you've set up your own APT repository:

```bash
sudo apt update
sudo apt install tamil-99-keyboard
sudo apt install tamil-phonetic-keyboard
```

## What the Packages Do

Both packages automatically:

1. Install required dependencies (ibus, ibus-m17n, ibus-gtk, ibus-gtk3)
2. Install ibus-qt4 if available (for older systems)
3. Start the IBus daemon
4. Set IBus as the default input method
5. Configure the appropriate Tamil keyboard layout:
   - `tamil-99-keyboard`: Configures Tamil 99 layout
   - `tamil-phonetic-keyboard`: Configures Tamil Phonetic layout
6. Restart IBus to apply changes

## Setting Up an APT Repository

To make these packages available via `apt install`, you need to set up a Debian repository:

### 1. Install Required Tools

```bash
sudo apt-get install reprepro gnupg
```

### 2. Create Repository Structure

```bash
mkdir -p /path/to/repo/{conf,dists,pool}
```

### 3. Create Repository Configuration

Create `/path/to/repo/conf/distributions`:

```
Origin: Your Name
Label: Tamil Keyboard Repository
Codename: stable
Architectures: amd64 i386 arm64
Components: main
Description: Tamil keyboard layout packages
SignWith: YOUR_GPG_KEY_ID
```

### 4. Add Packages to Repository

```bash
cd /path/to/repo
reprepro includedeb stable /path/to/tamil-99-keyboard_*.deb
reprepro includedeb stable /path/to/tamil-phonetic-keyboard_*.deb
```

### 5. Serve the Repository

You can serve the repository via HTTP/HTTPS. For example, using Apache or nginx, or simply using Python's HTTP server for testing:

```bash
cd /path/to/repo
python3 -m http.server 8000
```

### 6. Add Repository to Client Systems

On client systems, add the repository:

```bash
echo "deb http://your-server:8000 stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list
sudo apt update
sudo apt install tamil-99-keyboard
```

## Customization

Before building, you may want to customize:

1. **Maintainer Information**: Edit `debian/control` and `debian/changelog` in each package directory
2. **Copyright**: Edit `debian/copyright` in each package directory
3. **Version**: Update version in `debian/changelog`

## Package Structure

Each package contains:

- `debian/control`: Package metadata and dependencies
- `debian/rules`: Build instructions
- `debian/postinst`: Post-installation script (configures keyboard)
- `debian/postrm`: Post-removal script (cleanup)
- `debian/changelog`: Package changelog
- `debian/copyright`: Copyright information
- `debian/compat`: Debian compatibility level
- `debian/source/format`: Source package format

## Troubleshooting

### Package Build Fails

- Ensure all build dependencies are installed: `sudo apt-get install devscripts build-essential debhelper`
- Check that all scripts are executable: `chmod +x debian/rules debian/postinst debian/postrm`

### Keyboard Not Working After Installation

- Check if IBus is running: `pgrep ibus-daemon`
- Manually restart IBus: `killall ibus-daemon && ibus-daemon -drx`
- Check input sources: `gsettings get org.gnome.desktop.input-sources sources`
- Verify IBus is set as default: `im-config -m`

### gsettings Not Working

- Ensure you're running in a GNOME/GTK environment
- Try setting manually: `gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'in+eng'), ('ibus', 'm17n:ta:tamil99')]"`

## License

GPL-3.0+

