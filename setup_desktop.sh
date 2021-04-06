#!/bin/sh
# curl https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/setup_driver.sh | bash

DIR="/home/jovyan/.config/xfce4"

if [ -d "$DIR" ]; then
  # Take action if $DIR exists. #
  echo "Initizlized.. skipping..."
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Initizlizing..."
  mkdir -p "$DIR"
  wget -O $DIR/xfconf.zip https://github.com/L1NNA/L1NNA-peppapig/releases/download/dot/xfconf.zip
  unzip $DIR/xfconf.zip -d $DIR/
fi
