#!/bin/sh
# put other system startup commands here, the boot process will wait until they complete.
# Use bootlocal.sh for system startup commands that can run in the background 
# and therefore not slow down the boot process.

# initialize the Microkernel and start a few key services
/usr/bin/sethostname box
if [ -f /usr/local/etc/init.d/openssh ]
then
  sudo /usr/local/etc/init.d/openssh start
fi
sudo /usr/local/bin/rz_mk_init.rb
/opt/bootlocal.sh &
