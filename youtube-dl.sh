#!/usr/bin/env sh -eu
# -e If non interactive then exit immediately if a command fails.
# -u Treat unset variables as an error when substituting.

# Status: 4 Beta
# Requirement:
# Tested with: Debian and Ubuntu

## install requirement
apt install -y \
  ffmpeg

## if don't exist, download
[[ ! -f /usr/local/bin/youtube-dl ]] && \
sudo wget https://yt-dl.org/downloads/latest/youtube-dl -O /usr/local/bin/youtube-dl && \
sudo chmod a+rx /usr/local/bin/youtube-dl

## update
youtube-dl -U
