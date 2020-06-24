#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]
then
	echo "Sorry, you are not root."
	exit 1
fi

sudo mkdir -p /usr/local/scripts/
cp prepycheck.sh /usr/local/scripts/
chmod +x /usr/local/scripts/prepycheck.sh
echo "alias prepycheck='/usr/local/scripts/./prepycheck.sh'" >> ~/.bash_aliases
source ~/.bash_aliases