#!/bin/bash

SRC="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CHROMEDIR=/media/src/chromium

UTILSDIR=$HOME/src/misc/chrome
RULESREPO=$UTILSDIR/chromium-ubuntu-build
RULESDIR=$RULESREPO/debian

RULESREPOPATH="https://github.com/saiarcot895/chromium-ubuntu-build.git"

set -ex

# make sure the repo exists
if [ ! -d $RULESREPO ]; then
  mkdir -p $UTILSDIR

  pushd $UTILSDIR &> /dev/null
  git clone $RULESREPOPATH
  popd &> /dev/null
else
  pushd $RULESREPO &> /dev/null
  git pull
  popd &> /dev/null
fi

# read chrome version
CHROMEVER=$(head -1 $RULESDIR/changelog|awk -F\( '{print $2}'|sed -e 's/-.*//')
CHROMESRC=$CHROMEDIR/chromium-$CHROMEVER

if [ "$1" == "--clean=yes" ]; then
  rm -rf $CHROMESRC
fi

# grab source and extract
if [ ! -d $CHROMESRC ]; then
  pushd $CHROMEDIR &> /dev/null

  $SRC/grab-chrome-source.sh $CHROMEVER

  tar -xf chromium-browser_$CHROMEVER.orig.tar.xz

  popd &> /dev/null
fi

pushd $CHROMESRC &> /dev/null

if [ -d debian ]; then
  quilt pop -a -f || true
fi

# copy debian dir
rsync -a --delete $RULESDIR .

# delete bad patches
quilt delete -r title-bar-default-system.patch-v35 || true
quilt delete -r search-credit.patch || true
#quilt delete -r configuration-directory.patch || true

# apply patches
quilt import -f $SRC/disable-new-avatar-menu.patch || true
#quilt import -f $SRC/configuration-directory.patch || true

# taken from http://contribsoft.caixamagica.pt/browser/packages/anvil/chromium-browser/cmiffy/debdiff.patch
export GOOGLEAPI_APIKEY_UBUNTU=AIzaSyAQfxPJiounkhOjODEO5ZieffeBv6yft2Q
export GOOGLEAPI_CLIENTID_UBUNTU=424119844901.apps.googleusercontent.com
export GOOGLEAPI_CLIENTSECRET_UBUNTU=AIienwDlGIIsHoKnNHmWGXyJ

# fix issues
#dpkg-buildpackage -T override_dh_clean

# build
dpkg-buildpackage

popd &> /dev/null
