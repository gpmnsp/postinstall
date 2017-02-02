#!/bin/bash

# Postinstall Script v 0.7.9
# Description:
# This script makes most of the changes that I want for a freshly
# installed system. At the moment this is Linux Mint Cinnamon 18.
# This is work in progress. I'm just learning to write shell scripts.
# In the course of time the script will grow and get better, hopefully.

### ---> 1. edit hosts file: <--- ###

sudo sed -i '2i \
\n\#\ added per postinstall script\: \
144.076.082.011\t Hetz \
192.168.178.018\t Raspi \
192.168.178.001\t Fritz \
192.168.178.022\t Me1 \
192.168.178.028\t Me2 \
192.168.178.020\t VM-Cinna-18 \
192.168.178.021\t 1520 \
192.168.178.016\t ubulocalserv \
192.168.178.026\t Note8 \
\n\#\ blocking\: \
127.0.0.1\t google-analytics.com\n' \
/etc/hosts

### ---> 2. edit fstab and mounting smb shares: <--- ###
###  check the fstab file before running the script!!

### cifs and fuse config: ###
sudo cp /home/gpm/cifs.conf /etc/modprobe.d/
sudo cp /home/gpm/fuse.conf /etc/
sudo chown root:root /etc/modprobe.d/cifs.conf /etc/fuse.conf

### make mountpoints + preparation: ###
sudo mkdir /media/fritz /media/Hetz
sudo mkdir /media/Me1_e /media/Me1_j /media/Me1_m /media/Me1_w
sudo cp -t /root/ /home/gpm/.cred* ; sudo chown root:gpm /root/.cred*

### copy prepared fstab file: ###
sudo cp /etc/fstab /etc/fstab~
sudo cp /home/gpm/fstab /etc/  ; sudo chown root:gpm /etc/fstab
sudo chmod g+w /etc/fstab

### ---> 3. install apps after new sys installation <--- ###

### add needed PPAs: ###
sudo add-apt-repository -y ppa:anonbeat/guayadeque    # Guayadeque PPA
sudo add-apt-repository -y ppa:cairo-dock-team/ppa	   # Cairo-Dock PPA
sudo add-apt-repository -y ppa:nilarimogard/webupd8	  # PA-EQ etc. PPA
sudo add-apt-repository -y ppa:team-xbmc/ppa				      # Kodi PPA
sudo add-apt-repository "deb http://dl.google.com/linux/chrome/deb/ stable main"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo apt update																			                    # update packages

### install everything: ###
sudo apt install -y gir1.2-gtop-2.0									          # for Sys-Indicator
sudo apt install -y gigolo													               # Gigolo
sudo apt install -y dconf-editor									            	# dconf-Editor (misc system settings)
sudo apt install -y mc															                 # MC
sudo apt install -y htop														                # Htop
sudo apt install -y easystroke											             # Mouse buttons
sudo apt install -y screen													               # Screen
sudo apt install -y xfce4-terminal									           # XFCE4 Terminal
sudo apt install -y dropbox													              # Dropbox
 ## PA-EQ giving issues, canceled for now:
 # sudo apt install -y pulseaudio-equalizer					      # Pulseaudio EQ
sudo apt install -y cairo-dock cairo-dock-plug-ins	   # Cairo-Dock
sudo apt install -y guayadeque											             # Guayadeque
sudo apt install -y software-properties-common			     # Kodi
sudo apt install -y kodi														                # Kodi
sudo aptitude install google-chrome-stable					       # Google Chrome
 ## not needed, Calibre is allready installed portable in ~/bin, but keep it as fallback:
 # sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
## update the portable Calibre installation:
cd /home/gpm/bin
./calibre-portable.sh -u
cd

### optional: ###
sudo apt install -y ubuntu-restricted-addons \
ubuntu-restricted-extras														                # *1
sudo apt install -y libdvd-pkg											             # *2
echo "configuring libdvd-pkg..."
sudo dpkg-reconfigure libdvd-pkg
sudo apt install -y exfat-fuse exfat-utils					       # *3
sudo apt install -y samba cifs-utils fusesmb				      # *5
sudo apt install -y p7zip agave filezilla						       # *6
sudo apt purge -y skype thunderbird hexchat pidgin	   # remove superfluous
sudo apt update && sudo apt-get -y dist-upgrade			    # update packages & upgrade
sudo apt autoremove																	                  # janitoring

### install all .deb-archives in ~/Downloads/postinstall: ###
sudo dpkg -i -R --force-confdef --force-confold /home/gpm/Downloads/postinstall/ # Synergy issue!( *x)

### ---> 4. Tweaks <--- ###

## ( *x):
## edit avahi.daemon.conf: # @rlimit-nproc=3! (handles Synergy issue)
# we can't edit the file directly, so:
# create temp file first =>  cat /dir/file | sed -e "s/orig-line/new-line/" > /dir/tmpfile
sudo cat /etc/avahi/avahi-daemon.conf | sed -e "s/rlimit-nproc=3/#rlimit-nproc=3/" > /tmp/tmpfile
# copy temp file over original =>  mv /dir/tmpfile /dir/file
sudo mv /tmp/tmpfile /etc/avahi/avahi-daemon.conf
 ## not needed, as PA-EQ gets not intalled:
 #cp /home/gpm/default.pa /home/gpm/.config/pulse/		  #volume setting restore

sudo cp /home/gpm/environment /etc/environment				    #set PATH systemwide

echo ""
echo "Alles fertig! Neustarten!"
read -n 1 -s

# *1 Install restricted packages “ubuntu-restricted-addons” and “ubuntu-restricted-extras”.
#    Ubuntu-restricted-addons includes GStreamer, GStreamer plugins and libdvdread4
#    (library for reading DVD’s) ubuntu-restricted-extras includes the Adobe Flash plugin,
#    ffmpeg, lame (MP3 encoding library), and Microsoft TrueType fonts.
#sudo apt install -y ubuntu-restricted-addons ubuntu-restricted-extras
#
# *2 Enable DVD playback.
#sudo apt install -y libdvd-pkg
#
# *3 Install utils to mount exfat file systems
#sudo apt install -y exfat-fuse exfat-utils
#
# *4 Install some multi-media apps VLC, WinFF, and Devede and Handbrake:
#sudo apt install -y vlc vlc-plugin* winff devede handbrake soundconverter
#
# *5 Install additional Samba/CIFS utilities which are helpful
#sudo apt install -y samba cifs-utils fusesmb
#
# *6 Install other favorite utilities
#sudo apt install -y p7zip agave filezilla putty zim gwenview geeqie

