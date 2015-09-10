#!/usr/bin/env bash

#bundle
bundle install

#python libs
sudo easy_install pip
sudo pip install nose
sudo pip install poster
#sudo pip uninstall enum
sudo pip install enum34
sudo pip install gevent