#!/usr/bin/env bash

#brew
brew install pandoc
brew install libevent #for gevent

#bundle
bundle install

#python libs
sudo easy_install pip
pip install --user --upgrade
pip install --user --upgrade
pip install --user --upgrade
CFLAGS='-std=c99' pip install --user gevent --upgrade
sudo -H pip uninstall enum34 -y