#!/usr/bin/env bash
sudo mkdir -p /usr/local/scripts
cp prepycheck.sh /usr/local/scripts
chmod +x /usr/local/scripts/prepycheck.sh
echo "alias prepycheck='/usr/local/scripts/./prepycheck.sh'" >> ~/.bash_aliases
source ~/.bash_aliases