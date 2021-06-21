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
mkdir /tmp/cellprofilerstuff/backups
cp ./__init__.py /tmp/cellprofilerstuff
cp ./classify.py /tmp/cellprofilerstuff
cp ./setup.py /tmp/cellprofilerstuff/backups

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
# ~/CellProfiler/cellprofiler/gui/dialog.py --> 
# import wx
# class AboutDialogInfo(wx.adv.AboutDialogInfo)

#make backup:
cp ~/CellProfiler/cellprofiler/gui/dialog.py /tmp/cellprofilerstuff/backups
#replace import wx with import wx.adv to fix class call:
sudo sed -i 's/import wx/import wx.adv/g' ~/CellProfiler/cellprofiler/gui/dialog.py
sudo sed -i 's/(wx.AboutDialogInfo)/(wx.adv.AboutDialogInfo)/g' ~/CellProfiler/cellprofiler/gui/dialog.py

# ~/CellProfiler/cellprofiler/gui/tools.py
# import cStringIO --> from io import StringIO
# fd = CStringIO.StringIO() --> fd = StringIO()
#make backup:
cp ~/CellProfiler/cellprofiler/gui/tools.py /tmp/cellprofilerstuff/backups
#replace CStringIO.String() to StringIO()
sudo sed -i 's/import cStringIO/from io import StringIO/g' ~/CellProfiler/cellprofiler/gui/tools.py
sudo sed -i 's/cStringIO.StringIO()/StringIO()/g' ~/CellProfiler/cellprofilergui/tools.py

# ~/CellProfiler/cellprofiler/gui/errordialog.py
#import StringIO --> from io import StringIO
#make backup:
cp ~/CellProfiler/cellprofiler/gui/errordialog.py /tmp/cellprofilerstuff/backups
sudo sed -i 's/import StringIO/from io import StringIO/g' ~/CellProfiler/cellprofiler/gui/errordialog.py

# ~/cellProfiler/cellprofiler/gui/errordialog.py
# commented both import urllib and urllib2
# added: from urllib.request import urlopen
sudo sed -i 's/import urllib/#import urllib/g' ~/CellProfiler/cellprofiler/gui/errordialog.py
sudo sed -i 's/#import urllib2/from urllib.request import urlopen/g' ~/CellProfiler/cellprofiler/gui/errordialog.py

# ~/CellProfiler/cellprofiler/modules/loadimages.py:77
# import urlparse --> from urllib.parse import urlparse
# make backup: 
cp ~/CellProfiler/cellprofiler/modules/loadimages.py /tmp/cellprofilerstuff/backups
sudo sed -i 's/import urlparse/from urllib.parse import urlparse/g' ~/CellProfiler/cellprofiler/modules/loadimages.py 
sudo sed -i 's/import'

# ~/CellProfiler/cellprofiler/modules/images.py: can't find module _help
# resolution - relative path assignment:
cp ~/CellProfiler/cellprofiler/modules/images.py /tmp/cellprofilerstuff/backups
sudo sed -i 's/import _help/from . import _help/g' ~/CellProfiler/cellprofiler/modules/images.py

# ~/cellprofiler/cellprofiler/modules/images.py
# no modules named 'loadimages'
sudo sed -i 's/import loadimages/from . import loadimages/g' ~/CellProfiler/cellprofiler/modules/images.py

# ~/CellProfiler/cellprofiler/modules/loadimages.py : 95 --> no module named skimage.external
cp ~/CellProfiler/cellprofiler/modules/loadimages.py /tmp/cellprofilerstuff/backups
# apparently scikit-images no longer ships with tifffile so calling it directly is needed:
sudo sed -i 's/import skimage.external.tifffile/import tifffile/g' ~/CellProfiler/cellprofiler/modules/loadimages.py

# ~/CellProfiler/cellprofiler/gui/moduleview.py:8 --> no module named 'Queue'
cp ~/CellProfiler/cellprofiler/gui/moduleview.py /tmp/cellprofilerstuff/backups
sudo sed -i '/import Queue/import queue/g' ~/CellProfiler/cellprofiler/gui/moduleview.py
sudo sed -i '/Queue.Queue()/queue.Queue()/g' ~/CellProfiler/cellprofiler/gui/moduleview.py

# ~/CellProfiler/cellprofiler/gui/imagesetctrl.py:19 --> no moudle named 'wx.combo'
# currently broken --> unclear what replacement module name is, pending next patch





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