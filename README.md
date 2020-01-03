# CellProfiler_Ubuntu_Installer
Install script for CellProfiler v3.1.9 on Ubuntu 18.04.3 LTS(+) - bash, installs python3.6

proven to work on Ubuntu 18.04 and installs all dependencies. This script can be run line by line instead to get a functional version of CellProfiler installed. For support and queries, route to the Cellprofiler page on Github. This script is simply an installer to make it easier for users to get CellProfiler on their linux workstations with a supported version of python.


1. Clone this repo to your Target workstation desktop: 
> sudo git clone https://github.com/scotchman0/CellProfiler_Ubuntu_Installer.git

2. enter the target folder and make the Install target file exectuable: 
> sudo chmod a+x ./CellProfiler_Install.sh

3. Run the script with:
> sudo ./CellProfiler_Install.sh

4. There is a point about 3-5 minutes after you start the script that will require you to edit ~/Cellprofiler/setup.py to lower the required python version from 3.7 to 3.6. (3.7 seems to throw many more errors than 3.6). You should also be made aware that this script will set your default python3 and python variable to python3.6 for ease of install. You can set these back to a different version by simply installing a later version of python (which will update the python3 symlink), or by manually editing the link file in /usr/local/bin/ with: 
>   cd /usr/bin && rm ./python && ln -s python2.7 ./python
>   cd /usr/bin && rm ./python3 && ln -s python3.7 ./python3
(edit the before line to whatever version you want "python" to summon - vs python3 summoning build of 3.5/3.7 etc)

Submit some issue logs here if you run into trouble - usually the big issue is that Javabridge will claim to not be installed (but it is). It got installed in the wrong spot. There's a line that fixes this in the current build: 

> mv ~/.local/lib/python3.6/site-packages/* /usr/local/lib/python3.6/dist-packages/

you shouldn't need to do much with this, just know that it's happening (moving the javabridge install baseline into the correct spot). 