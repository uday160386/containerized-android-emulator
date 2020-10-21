#!/bin/bash

#Retrieving the select emulator devices
DEVICE_LIST=$1

#Storing the Selenium Grid details
SELENIUM_HOST=$2
SELENIUM_PORT=$3
ANDROID_EMULATOR=$4

compose_device_to_appium_json() {
  echo "{\"capabilities\":[{\"deviceName\": \"$1\",\"browserName\": \"chrome\",\"version\":\"11.0\",\"maxInstances\": 2,\"platform\":\"Android\"}],\"configuration\":{\"cleanUpCycle\":3000,\"timeout\":30000,\"proxy\": \"org.openqa.grid.selenium.proxy.DefaultRemoteProxy\",\"url\":\"http://$4:$2/wd/hub\",\"host\": \"$4\",\"port\": $2,\"maxSession\": 2,\"register\": true,\"registerCycle\": 5000,\"hubPort\": $SELENIUM_PORT,\"hubHost\": \"$SELENIUM_HOST\"}}"> /opt/appium/json/$1.json
}
#clean up of existing json files
rm -rf /opt/appium/json
IFS=',' 
mkdir -p /opt/appium/json

var="* a  *"
read -ra arr <<<"$DEVICE_LIST" 
for a in "${arr[@]}"
do  
   if [ $a == "Nexus-1" ]
   then
      compose_device_to_appium_json $a 5557
    #########################Attaching Emulators to Appium and SeleniumGrid ############
      nohup appium -p 4723 -bp 4724 --nodeconfig /opt/appium/json/"$a".json > appium_emulator_info_log.out 2>&1 &
   elif [ $a == "Nexus-2" ]
   then
      compose_device_to_appium_json $a 5559
      ###################### Attaching Emulators to Appium and SeleniumGrid ############
      nohup appium -p 4725 -bp 4726 --nodeconfig /opt/appium/json/Nexus-2.json > appium_emulator_info_log.out 2>&1 &
   else
      echo "No Devices exists!"
   fi
done 
echo "Devices are available through Selenium Grid: http://$SELENIUM_HOST:$SELENIUM_PORT/wd/hub" 
 
