#!/bin/bash
#Cellprofiler install: Ubuntu 18.04 LTS rework
#publish date: 6/16/21
#version: 0.2
#author: Will Russell (Scotchman0)
#All this does is make your 18.04LTS system compatible with CellProfiler, and I claim no 
#ownership or support for the end product which is maintained by the fantastic developers
#at https://github.com/cellprofiler/cellprofiler. Hopefully this helps you run CellProfiler
#on your 18.04LTS endpoint. (support for 20.04LTS untested at this time)


#BASE SOFTWARE INSTALLATION BLOCK:
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y \
    build-essential    \
    cython             \
    git                \
    libmysqlclient-dev \
    libhdf5-dev        \
    libxml2-dev        \
    libxslt1-dev       \
    openjdk-8-jdk      \
    python-dev         \
    python-pip         \
    python-h5py        \
    python-matplotlib  \
    python-mysqldb     \
    python-scipy       \
    python-numpy       \
    python-pytest      \
    python-vigra       \
    python-wxgtk3.0    \
    python-zmq

#MOVE SECONDARY ASSETS TO INSTALL SPACE:
mkdir /tmp/cellprofilerstuff
cp ./__init__.py /tmp/cellprofilerstuff
cp ./classify.py /tmp/cellprofilerstuff
cp ./setup.py /tmp/cellprofilerstuff

#CLONE THE REPOSITORY:
echo "cloning the CellProfiler Repository to user home dir"
cd ~/ && git clone https://github.com/CellProfiler/CellProfiler
sleep 2
cd ~/CellProfiler
git checkout v3.1.9

#PRE_PATCH CYTHON:
sudo pip install --upgrade cython

#INSTALL CELLPROFILER:
sudo pip install --user --editable .

#SET USER BASE:
python -m site --user-base

#ADD PATH TO YOUR LOCAL ENVIRONMENT TO START PIP PACKAGES:
export PATH="$HOME/.local/bin:$PATH"

#ADVISE USER CAN START CELLPROFILER WITH 'CELLPROFILER + LAUNCH:'
echo "CellProfiler 3.1.9 is now installed. Script will attempt to auto-launch. If it fails"
echo "try again with sudo as shown here: $ sudo cellprofiler"