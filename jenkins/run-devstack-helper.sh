#!/bin/bash

set -eux

thisdir=$(dirname $(readlink -f "$0"))

. "$thisdir/common.sh"

server="${Server-$TEST_XENSERVER}"
stackdir="/tmp/stack"

# Install basics for vi and git
yum -y  --enablerepo=base install gcc make vim-enhanced zlib-devel openssl-devel

# Simple but usable vimrc
if [ ! -e /root/.vimrc ]; then
    cat > /root/.vimrc <<EOF
syntax on
se ts=4
se expandtab
se shiftwidth=4
EOF
fi

# Use the pretty vim
if [ -e /usr/bin/vim ]; then
    rm /bin/vi
    ln -s /usr/bin/vim /bin/vi
fi

# Install git 
if ! which git; then
    DEST=/tmp/
    GITDIR=$DEST/git-1.7.7
    cd $DEST
    rm -rf $GITDIR*
    wget http://git-core.googlecode.com/files/git-1.7.7.tar.gz
    tar xfv git-1.7.7.tar.gz
    cd $GITDIR
    ./configure
    make install
fi

cd $stackdir

cd devstack
git checkout xenservermodif

cd $stackdir/devstack
defaultlocalrc="http://gold.eng.hq.xensource.com/localrc"
lrcurl="${localrcURL-$defaultlocalrc}"
if [ ! -f localrc ]
then
    wget $lrcurl
fi

cd tools/xen
./build_xva.sh

