#!/bin/sh

echo "Upgrading packages..."
sudo apt-get update

# Verificar si Linuxbrew está instalado
if ! command -v brew >/dev/null 2>&1
then
    echo "Installing Linuxbrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Linuxbrew already installed."
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Installing linuxbrew dependencies..." 
sudo apt-get install build-essential

echo "Installing gcc..."
brew install gcc

echo "Upgrading all dependencies..."
brew upgrade

echo "Linuxbrew installed and configured successfully!"