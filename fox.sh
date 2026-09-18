#!/bin/bash
# A curious little script to change Fedora into FoxOS!

# The Queen of Hearts demands root privileges for such nonsense!
if [ "$EUID" -ne 0 ]; then
  echo "Oh my ears and whiskers! You must run this with sudo, or it simply won't do!"
  exit 1
fi

echo "Down the rabbit hole we go! Painting the system name..."

# We must back up the original looking-glass, just in case we wish to go back
cp /usr/lib/os-release /usr/lib/os-release.wonderland_backup

# Changing the names to our fox theme
sed -i --follow-symlinks 's/^NAME=.*/NAME="FoxOS"/' /etc/os-release
sed -i --follow-symlinks 's/^PRETTY_NAME=.*/PRETTY_NAME="FoxOS KDE Edition"/' /etc/os-release
sed -i --follow-symlinks 's/^ID=fedora/ID=foxos/' /etc/os-release

echo "Fetching a proper fox for the icon..."
# Downloading a lovely public domain fox face to your system pixmaps
curl -s -o /usr/share/pixmaps/fox-logo.svg "https://upload.wikimedia.org/wikipedia/commons/4/43/Fox_face_emoji.svg"

echo "The potion is drunk! Your system is now FoxOS."
echo "To see the new name, open your terminal or system settings. It gets curiouser and curiouser!"
