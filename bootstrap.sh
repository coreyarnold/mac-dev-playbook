#!/bin/sh

# Welcome to the siyelo laptop script!
# Be prepared to turn your OSX box into 
# a development beast.
#
# This script bootstraps our OSX laptop to a point where we can run
# Ansible on localhost. It;
#  1. Installs 
#    - xcode
#    - homebrew
#    - ansible (via brew) 
#    - a few ansible galaxy playbooks (zsh, homebrew, cask etc)  
#  2. Kicks off the ansible playbook
#    - main.yml
#
# It will ask you for your sudo password

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

fancy_echo "Boostrapping ..."

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
# sudo -v
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Ensure Apple's command line tools are installed
if ! command -v cc >/dev/null; then
  fancy_echo "Installing xcode ..."
  xcode-select --install 
else
  fancy_echo "Xcode already installed. Skipping."
fi

if ! command -v brew >/dev/null; then
  fancy_echo "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
else
  fancy_echo "Homebrew already installed. Skipping."
fi

# [Install Ansible](http://docs.ansible.com/intro_installation.html).
if ! command -v ansible >/dev/null; then
  fancy_echo "Installing Ansible ..."
  brew install ansible 
else
  fancy_echo "Ansible already installed. Skipping."
fi

fancy_echo "Changing to repo dir ..."
[ ! -d ~/Development/  ] && mkdir ~/Development/
cd ~/Development/

# Clone the repository to your local drive.
if [ -d ~/Development/mac-dev-playbook ]; then
  fancy_echo "repo dir exists. Removing ..."
  rm -rf ~/Development/mac-dev-playbook/
fi
fancy_echo "Cloning repo ..."
git clone https://github.com/coreyarnold/mac-dev-playbook.git 

fancy_echo "Changing to repo dir ..."
cd ~/Development/mac-dev-playbook/

# Run this from the same directory as this README file. 
fancy_echo "Installing ansible roles"
ansible-galaxy install -r requirements.yml
fancy_echo "Running ansible playbook ..."
ansible-playbook main.yml -i inventory --ask-sudo-pass -vvvv 