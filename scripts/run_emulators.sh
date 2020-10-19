#!/bin/bash
#Storing the Selenium Grid details
SELENIUM_HOST=$2
SELENIUM_PORT=$3
## Retrieving the select emulator devices
DEVICE_LIST=$1

#Device List and public names
DEVICE_1="Nexus-1"
DEVICE_2="Nexus-2" 

start_emulator() {
  nohup emulator -avd $1 -no-accel -no-window -no-audio -ports $2 -gpu swiftshader_indirect -read-only> emulator_info_log.out 2>&1 &
}
############################################# Installing System Images ################################################
#System Images List
IMAGE_1="system-images;android-${ANDROID_API_LEVEL};google_apis;x86"
IMAGE_2="system-images;android-${ANDROID_API_LEVEL};google_apis;x86_64"

echo y | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} $IMAGE_1
echo y | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} $IMAGE_2
echo y | /opt/android-sdk/cmdline-tools/tools/bin/sdkmanager --update 

############################################# Creating and Managing AVD ################################################

# Configuring Android Emulators
echo no | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/avdmanager create avd -n $DEVICE_1 --abi google_apis/x86 -k $IMAGE_1
echo no | ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/avdmanager create avd -n $DEVICE_2 --abi google_apis/x86_64 -k $IMAGE_2
echo y | /${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin/sdkmanager --update
echo "Available Devices: 1. $DEVICE_1 2. $DEVICE_2"

############################################# Running Emulators ################################################
#Kill emulator if exists
adb -s emulator-5556 emu kill
adb -s emulator-5558 emu kill
adb kill-server
#starting emulators in backgroud with ports: Devcie-1: 5556 and 5557(tcp)
start_emulator $DEVICE_1 5556,5557
#starting emulators in backgroud with ports: Devcie-1: 5558 and 5559(tcp)
start_emulator $DEVICE_2 5558,5559
n=1
while [[ `adb -s emulator-5556  get-state` != 'device' ]]; do sleep 30;echo "retry $n times.";n=$(( n+1 )); done;
#Running emulators in backgroud with ports: Devcie-2: 5558 and 5559(tcp)
n=1
while [[ `adb -s emulator-5558  get-state` != 'device' ]]; do sleep 30;echo "retry $n times.";n=$(( n+1 )); done;
echo "Devices are up & running!" 