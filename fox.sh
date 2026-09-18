#!/bin/bash
# A very curious potion to transform Fedora KDE into FoxOS!

# The Queen of Hearts demands root privileges!
if [ "$EUID" -ne 0 ]; then
  echo "Oh my ears and whiskers! You must run this with sudo, or it simply won't do!"
  exit 1
fi

# We must remember who you are, the real Alice, not the root user!
REAL_USER=${SUDO_USER:-$(who am i | awk '{print $1}')}
USER_HOME=$(eval echo ~$REAL_USER)
LOGO_PATH="$USER_HOME/Downloads/logo.png"
DEST_BG="/usr/share/backgrounds/fox-wallpaper.png"

# Let us check if the White Rabbit actually left the logo where he promised...
if [ ! -f "$LOGO_PATH" ]; then
    echo "Oh dear! Oh dear! I shall be too late! I cannot find logo.png in $USER_HOME/Downloads/!"
    echo "Please put the logo.png file there and try drinking the potion again."
    exit 1
fi

echo "Down the rabbit hole we go! Painting the system name..."
cp /usr/lib/os-release /usr/lib/os-release.wonderland_backup
sed -i --follow-symlinks 's/^NAME=.*/NAME="FoxOS"/' /etc/os-release
sed -i --follow-symlinks 's/^PRETTY_NAME=.*/PRETTY_NAME="FoxOS KDE Edition"/' /etc/os-release
sed -i --follow-symlinks 's/^ID=fedora/ID=foxos/' /etc/os-release

echo "Moving your lovely fox portrait into the system's looking-glass..."
mkdir -p /usr/share/backgrounds/
cp "$LOGO_PATH" "$DEST_BG"
chmod 644 "$DEST_BG"

echo "Painting the SDDM login screen..."
# SDDM theme configuration for the Breeze theme
mkdir -p /usr/share/sddm/themes/breeze/
cat <<EOF > /usr/share/sddm/themes/breeze/theme.conf.user
[General]
background=$DEST_BG
type=image
EOF

echo "Brewing the Plymouth boot splash... this part takes a moment of concentration!"
# We copy the default spinner theme and make it our own
PLYMOUTH_DIR="/usr/share/plymouth/themes/foxos"
mkdir -p "$PLYMOUTH_DIR"
cp -r /usr/share/plymouth/themes/spinner/* "$PLYMOUTH_DIR/"
mv "$PLYMOUTH_DIR/spinner.plymouth" "$PLYMOUTH_DIR/foxos.plymouth"

# Change the name inside the magical plymouth file
sed -i 's/Name=Spinner/Name=FoxOS/' "$PLYMOUTH_DIR/foxos.plymouth"
sed -i 's/spinner/foxos/g' "$PLYMOUTH_DIR/foxos.plymouth"

# Replace the watermark with your fox logo
cp "$DEST_BG" "$PLYMOUTH_DIR/watermark.png"

# Tell the system to use our new splash and rebuild the boot image!
plymouth-set-default-theme -R foxos

echo "Finally, spreading the picnic blanket (setting your desktop wallpaper)..."
# We must ask KDE nicely as your regular user, not as root!
sudo -u $REAL_USER env XDG_RUNTIME_DIR=/run/user/$(id -u $REAL_USER) plasma-apply-wallpaperimage "$DEST_BG"

echo "Wake up, wake up! The potion has been drunk."
echo "Your system is entirely FoxOS now. You may want to restart the computer to see the boot splash and login screen in all their glory!"
