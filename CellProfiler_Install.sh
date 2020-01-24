#!/bin/bash
#This script is to facilitate and install CellProfiler 3.1.x and target bundle modules like classifypixels-unet.
#Built for Ubuntu 18.04 LTS. 
#Written by William Russell at Duke University for Dr. Ravi Karra
#Hosted for public use on Github - installation directories and instructions modified from originals found at
#github.com/CellProfiler/CellProfiler

RED=$(printf "\033[31m")
END=$(printf "\033[0m")

echo "installing dependencies and plugins:"
#install the required dependencies:
apt-get install -y \
    build-essential    \
    cython             \
    git                \
    libmysqlclient-dev \
    libhdf5-dev        \
    libxml2-dev        \
    libxslt1-dev       \
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
    python-zmq         \
    libssl-dev         \
    libgtk-3-dev

sleep 2


#moving secondary assets to a temp space for install later:
mkdir /tmp/cellprofilerstuff
cp ./__init__.py /tmp/cellprofilerstuff
cp ./classify.py /tmp/cellprofilerstuff

#clone the repo:
echo "cloning the Git Repository"
cd ~/ && git clone https://github.com/CellProfiler/CellProfiler
sleep 2
git checkout v3.1.9


#install python3.6
echo "installing python 3.6"
sleep 2
apt install python3.6 -y
sleep 2

#Install correct version of pip:
echo "installing pip"
sleep 2
apt install python3-pip -y
python3.6 -m pip install pip
sleep 2

#set Symlinks to aim at correct version of python
echo "establishing symlinks to default python3.6"
sleep 2
cd /usr/bin && rm ./python && ln -s python3.6 ./python
cd /usr/bin && rm ./python3 && ln -s python3.6 ./python3


#install correct version of JAVA (openJDK8)
echo "installing OpenJDK8"
sleep 2
wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
apt-get install -y software-properties-common
add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
apt-get install -y adoptopenjdk-8-hotspot
echo "OpenJDK installed."
sleep 2

#set default java to target install DIR
cd /usr/lib/jvm/ && rm default-java && ln -s java-8-opendjk-amd64 default-java


echo "verifing java version:"
sleep 2
java -version
sleep 2

#Install more library modules as required by cellprofiler
echo "installing library modules with PIP as required by CellProfiler"
sleep 2
cd ~/CellProfiler
python -m pip install requests keras numpy
python -m pip install -U six wheel setuptools testresources cython

#ensures that module: apt_pkg is installed:
echo "reinstalling python3-apt because sometimes this is broken"
sleep 2
apt-get install --reinstall python3-apt

#create symlink that will properly call apt_pkg as a module/library:
echo "creating symlink for apt_pkg in /usr/lib/python3/dist-packages"
sleep 2
cd /usr/lib/python3/dist-packages/ && ln -s apt_pkg.cpython-36m-x86_64-linux-gnu.so apt_pkg.so

echo "${RED}before we proceed to the next step, open a new tab in terminal edit the file ~/Cellprofiler/setup.py${END}"
echo "${RED}on line 84 - change the python_requires>=3.7 to 3.6${END}"
echo "then press return to continue script once the change is completed."
read response4

echo "installing CellProfiler . . ."
sleep 2
echo "${RED}However, this may take a long time - up to an hour. Go get some tea. I promise it will compile.${END}"
echo "and press [return] to kick it off."
read response4
sleep 1
echo "installing wxPython - the long bit"
sleep 2

mkdir /opt/wxpython
cd /opt/wxpython
python3.6 -m pip download wxPython
python3.6 -m pip wheel -v wxPython-*.tar.gz 2>&1 | tee build.log
python3.6 -m pip install ./wxPython-*.whl


echo "DING! wxPython completed, and you were patient! Now installing the actuall app you came for - CellProfiler"
sleep 5

#install JAVAbridge (requires targeting the OpenJDK directory)
echo "setting up JavaBridge..."
cd /usr/lib/jvm/adoptopenjdk-8-hotspot-amd64 && JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64 pip install javabridge --user
export JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/
#Install path at: /home/dhtsadmin/.local/lib/python3.6/site-packages/javabridge

#sometimes Javabridge gets installed in the wrong spot because why not
echo "moving javabridge to where it needs to live - if you get errors here, this is fine"
echo "means it worked right the first time"

sleep 2
mv ~/.local/lib/python3.6/site-packages/* /usr/local/lib/python3.6/dist-packages/


echo "installing cellprofiler"
#Install CellProfiler
sleep 2
cd ~/CellProfiler && python3.6 -m pip install --editable .
sleep 5

#clone the additional resources into place, then puts them in the default folder location:
echo "cloning plugins and moving them up one level to default plugins directory"
cd ~/CellProfiler/plugins && git clone https://github.com/CellProfiler/Cellprofiler-Plugins
#sleep 1
#mv ~/Cellprofiler/plugins/Cellprofiler-Plugins/* ~/CellProfiler/plugins/
mv ~/CellProfiler/plugins/Cellprofiler-Plugins/* ~/CellProfiler/plugins/


#added modified versions of __init__.py to /cellprofiler/modules to add default baseline files
#copied from /tmp/cellprofilerstuff/ 
cd ~/CellProfiler/plugins && cp classifypixelsunet.py ~/CellProfiler/cellprofiler/modules
cp /tmp/cellprofilerstuff/* ~/CellProfiler/cellprofiler/modules/
cp ~/CellProfiler/plugins/


#Create a start command "CellProfiler" as an export so you can call it directly in terminal
echo "adding cellprofiler as an export from /usr/local/bin"
python -m site --user-base
export PATH="$HOME/.local/bin:$PATH"

#install tensorflow *(required for keras init of classifypixelsunet.py)
python3.6 -m pip install tensorflow

#patch added 1_20_20: - botocore has an interdependency error that requires a manual re-installation to the latest patch version:
#otherwise clashes with docutils
python -m pip uninstall botocore -y
python -m pip install botocore

#install requirements for plugins:
cd ~/Cellprofiler/plugins && pip install requirements.txt

echo "Cellprofiler should now launch - may take a few moments for initialization..."
echo "Don't forget to submit bugs via the git page and make adjustments/pulls as you see fit, generally I'll push them"
echo "relatively swiftly... Cheers".
echo "if cellprofiler starts - I HIGHLY recommend a restart before you dive in."

cellprofiler

exit 0

