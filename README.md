# Tamil Keyboard APT Repository

This directory contains the Debian APT repository for Tamil keyboard packages.

## Repository Structure

- `pool/` - Contains the actual .deb package files
- `dists/` - Contains repository metadata (Packages, Release files)

## For Users

To use this repository, add it to your system:

```bash
echo "deb https://khaleeljageer.github.io/tamil-keyboard stable main" | sudo tee /etc/apt/sources.list.d/tamil-keyboard.list

wget -qO - https://khaleeljageer.github.io/tamil-keyboard/public-key.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tamil-keyboard.gpg

sudo apt update
sudo apt install tamil-keyboard
```

Then enable a layout as your normal user:

```bash
tamil-keyboard-setup tamil99
```

This repository is automatically updated by GitHub Actions when new releases are tagged.
