#!/bin/sh

#Load in the console's enviornment variables
source /etc/preinit
script_init

# Kill it! Kill it with fire!
pkill -KILL clover-mcp

#Clear cache and inodes for good measure...
echo 3 > /proc/sys/vm/drop_caches

dd if=/dev/zero of=/dev/fb0 #Clear FB just in case...

WorkingDir=$(pwd)
GameName=$(echo $WorkingDir | awk -F/ '{print $NF}')
ok=0

if [ -f "/usr/share/games/$GameName/$GameName.desktop" ]; then
	QuakeTrueDir=$(grep /usr/share/games/$GameName/$GameName.desktop -e 'Exec=' | awk '{print $2}' | sed 's/\([/\t]\+[^/\t]*\)\{1\}$//')
	ok=1
fi

if [ "$ok" == 1 ]; then

  decodepng "$QuakeTrueDir/Hakchi_Quake_assets/q1splash-min.png" > /dev/fb0;

  #LOADING THE GAME FROM HERE ####

  #Dynamically link the SDL2.0 library on the mini
  [ ! -L $QuakeTrueDir/lib/libSDL2-2.0.so.0 ] && ln -sf "/usr/lib/libSDL2.so" "$QuakeTrueDir/lib/libSDL2-2.0.so.0"
  [ ! -L $QuakeTrueDir/lib/libvchiq_arm.so ] && ln -sf "/usr/lib/libMali.so" "$QuakeTrueDir/lib/libvchiq_arm.so"

  #Load in the extra libraries required to run on SNESC
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$QuakeTrueDir/lib
  export LD_LIBRARY_PATH

  #Change the HOME environment variable for running on the mini...
  HOME=$QuakeTrueDir
  export HOME
  
  cd $QuakeTrueDir

  chmod +x /media/ldd

  sh /media/ldd $QuakeTrueDir/tyrquake/bin/tyr-quake &> /media/quake1test_ldd.log

  $QuakeTrueDir/tyrquake/bin/tyr-quake &> /media/quake1_SA.log

  echo 3 > /proc/sys/vm/drop_caches #Clear down after ourselves...

  echo $(free -m) >> /media/quake1_SA_ram_test.log #Check we haven't fucked the console...

  /etc/init.d/S81clover-mcp start #Restart Clover UI and MCP

else
	decodepng "$QuakeTrueDir/Hakchi_Quake_assets/q1error_files-min.png" > /dev/fb0;
	sleep 5
  /etc/init.d/S81clover-mcp start #Restart Clover UI and MCP
fi