#!/usr/bin/env bash

#brew
brew install pandoc

#bundle
bundle install

#python libs
sudo easy_install pip
sudo -H pip install nose --upgrade
sudo -H pip install poster --upgrade
sudo -H pip install enum34 --upgrade
sudo -H pip install gevent --upgrade
sudo -H pip uninstall enum34 -y