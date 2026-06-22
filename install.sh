#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./install.sh"
  exit 1
fi

# Get the username of the actual user running the script
if [ -n "$SUDO_USER" ]; then
  username="$SUDO_USER"
else
  username=$(id -nu 1000 2>/dev/null || echo "$USER")
fi
builddir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# ==============================
# Setup user directories
# ==============================
cd $builddir

mkdir -p /home/$username/.config
mkdir -p /home/$username/.local/share/fonts
mkdir -p /home/$username/Pictures

cp -R config/* /home/$username/.config/
cp bg.jpg /home/$username/Pictures/background.jpg

if [ -f user-dirs.dirs ]; then
  mv user-dirs.dirs /home/$username/.config
fi

# ==============================
# Xresources setup
# ==============================
cp .Xresources /home/$username/
cp .Xnord /home/$username/

# Fix ownership BEFORE xrdb
chown -R $username:$username /home/$username

# Load Xresources as USER (IMPORTANT)
sudo -u $username xrdb -merge /home/$username/.Xresources

# ==============================
# Install essential packages
# ==============================
nala install -y \
feh bspwm sxhkd rofi polybar picom lxpolkit \
x11-xserver-utils unzip yad wget pulseaudio pavucontrol \
flameshot psmisc lxappearance papirus-icon-theme fonts-noto-color-emoji

# ==============================
# Fonts
# ==============================
cd $builddir

nala install -y fonts-font-awesome

# Download nerd fonts, only proceed with extraction if download succeeds
if wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip; then
  unzip -q -o FiraCode.zip -d /home/$username/.local/share/fonts
  rm -f FiraCode.zip
else
  echo "Warning: Failed to download FiraCode.zip"
fi

if wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip; then
  unzip -q -o Meslo.zip -d /home/$username/.local/share/fonts
  rm -f Meslo.zip
else
  echo "Warning: Failed to download Meslo.zip"
fi

# Only copy fontawesome otf files if they exist in the repository
if ls fonts/fontawesome/otfs/*.otf >/dev/null 2>&1; then
  mv fonts/fontawesome/otfs/*.otf /home/$username/.local/share/fonts/
fi

chown -R $username:$username /home/$username/.local/share/fonts

fc-cache -fv

# ==============================
# Cursor theme
# ==============================
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors
./install.sh
cd $builddir
rm -rf Nordzy-cursors

# ==============================
# Enable system GUI (optional)
# ==============================
# systemctl enable lightdm
# systemctl set-default graphical.target

# ==============================
# Polybar config scripts
# ==============================
bash scripts/changeinterface
bash scripts/usenala