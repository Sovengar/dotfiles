#!/bin/sh

# Create directory if it doesn't exist
mkdir -p ~/.local/bin

# Download yadm
curl -sfLo ~/.local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm

# Give execute permissions to yadm
chmod a+x ~/.local/bin/yadm

# Extract dotfiles from the repo to their respective locations on the system
# Executes bottstrap file which is the file that contains the commands for bootstrapping
~/.local/bin/yadm clone --bootstrap -f https://github.com/sovengar/.dotfiles-linux.git

# Clean up by removing yadm
rm -rf ~/.local/bin/yadm

echo "Dotfiles setup completed!"