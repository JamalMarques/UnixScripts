#!/bin/bash

echo "Starting process: $(date)"
echo " "

fastboot flash userdata ./zero-omni-atlas-size.img
fastboot flash userdata ./one-omni-atlas-size.img
fastboot flash userdata ./rand-omni-atlas-size.img
fastboot format userdata
fastboot -w
#fastboot flash userdata ./userdata-atlas-new.img
#fastboot reboot

echo " "
echo "End process: $(date)"

