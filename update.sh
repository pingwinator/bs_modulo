#!/usr/bin/env bash

#brew
brew install pandoc

#bundle
bundle install

#python libs
sudo easy_install pip
sudo -H pip install nose
sudo -H pip install poster
sudo -H pip install enum34
sudo -H pip install gevent