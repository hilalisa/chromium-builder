#!/bin/bash

VER=$1

if [ -z "$VER" ]; then
  echo "error: must specify version"
  exit 1
fi

DLDIR="https://commondatastorage.googleapis.com/chromium-browser-official"

SRCBALL=chromium-browser_$VER.orig.tar.xz

set -ex

if [ ! -f $SRCBALL ]; then
  wget -O $SRCBALL $DLDIR/chromium-$VER.tar.xz
fi
