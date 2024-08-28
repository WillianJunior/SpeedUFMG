#!/bin/bash
echo ----------------------------------------------------
echo AAAAAAAAAAAAAAAAAAAAAAAH
echo $(hostname) cannnot be directly accessed
echo This bash can only manage public keys for tunelling
echo ----------------------------------------------------
echo Your current keys:
if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
	chmod 0700 ~/.ssh
fi
if [ ! -f ~/.ssh/authorized_keys ]; then
        touch ~/.ssh/authorized_keys
        chmod 0644 ~/.ssh/authorized_keys
fi
cat ~/.ssh/authorized_keys
echo ----------------------------------------------------
echo Input options for:
echo  - 1 - Add new key
echo  - 2 - Delete all keys
read -p "Option: " OP

if [ $OP -eq 1 ]; then
	read -p "Paste your key: " NEW_KEY
	echo $NEW_KEY
	echo $NEW_KEY >> ~/.ssh/authorized_keys
	echo Added new key
elif [ $OP -eq 2 ]; then
	echo "" > ~/.ssh/authorized_keys
	echo All keys cleared
fi
echo bye...
