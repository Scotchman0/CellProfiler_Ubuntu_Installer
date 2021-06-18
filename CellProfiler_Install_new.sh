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
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    build-essential    \
    cython3             \
    git                \
    libmysqlclient-dev \
    libhdf5-dev        \
    libxml2-dev        \
    libxslt1-dev       \
    openjdk-8-jdk      \
    python3-dev         \
    python3-pip         \
    python3-h5py        \
    python3-matplotlib  \
    python3-mysqldb     \
    python3-scipy       \
    python3-numpy       \
    python3-pytest      \
    python-vigra       \
    python-wxgtk3.0    \
    python3-zmq         \
    python3-wxgtk4.0    


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


#PRE_PATCH builds:
sudo pip3 install --upgrade cython
sudo pip3 install --upgrade scipy
sudo pip3 install --upgrade scikit-image==0.17.2
sudo pip3 install numpy==1.18.2

#COPY IN MODIFIED SETUP.PY:
cp /tmp/cellprofilerstuff/setup.py ~/CellProfiler

#MODIFICATIONS BLOCK:
#sed -i 's/old-text/new-text/g' input.txt
#MODIFICATION STACK TO GET THINGS RUNNING:
# https://github.com/CellProfiler/CellProfiler/issues/2829
# ~/default-java/cellprofiler/gui/dialog.py --> 
# import wx.adv
# class AboutDialogInfo(wx.adv.AboutDialogInfo)

# ~/CellProfiler/cellprofiler/gui/tools.py
# import cStringIO --> from io import StringIO
# fd = CStringIO.StringIO() --> fd = StringIO()

# ~/CellProfiler/cellprofiler/gui/errordialog.py
#import StringIO --> from io import StringIO

# ~/cellProfiler/cellprofiler/gui/errordialog.py
# commented both import urllib and urllib2
# added: from urllib.request import urlopen

# ~/cellprofiler/cellprofiler/modules/images.py 78 -->
# removed import urlparse
# added from urllib.parse import urlparse

# ~/cellprofiler/cellprofiler/modules/loadimages.py
# removed import _help

# ~/cellprofiler/cellprofiler/modules/images.py
# removed import loadimages (6)



#INSTALL CELLPROFILER:
sudo pip3 install --editable . #removed --user flag

#SET USER BASE:
python3 -m site --user-base

#ADD PATH TO YOUR LOCAL ENVIRONMENT TO START PIP PACKAGES:
export PATH="$HOME/.local/bin:$PATH"

#ADVISE USER CAN START CELLPROFILER WITH 'CELLPROFILER + LAUNCH:'
echo "CellProfiler 3.1.9 is now installed. Script will attempt to auto-launch. If it fails"
echo "try again with sudo as shown here: $ sudo cellprofiler"


#########################################################################################
#REPAIR BLOCK FOR COMPATIBILITY#