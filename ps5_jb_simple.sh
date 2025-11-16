#!/bin/bash

# This jailbreak is a simple jailbreak script that only sends the Lapse exploit and etaHEN payload to the PS5 via PC, no autoloader.

# This jailbreak does:
# 1) Prerequisite: Install the modified Youtube app by restoring console from Y2JB backup.
# 2) Send Lapse exploit and etaHEN payload to PS5 to enable jailbreak.

# PS5 Jailbreak configuration
GIT_Y2JB_DIR="./github-Y2JB"
PS5_HEN_DIR="."
PS5_IP="192.168.14.158"

# Send the lapse exploit payload
python3 "$GIT_Y2JB_DIR/payload_sender.py" "$PS5_IP" 50000 "$GIT_Y2JB_DIR/payloads/lapse.js"

# Wait for a few seconds to ensure the exploit is processed
sleep 5

# Send the HEN payload
python3 "$GIT_Y2JB_DIR/payload_sender.py" "$PS5_IP" 9021 "$PS5_HEN_DIR/251111 etaHEN-2.3B.bin"







### HOW TO SETUP THE FIRST TIME
# Install the modified Youtube app.
	# Options: a) Restore console from Y2JB.
	# b) get download0.dat (336 MB) from ps5_y2jb_autoloader and place it in /user/download/PPSA01650. This will update the current Youtube app. But remember!

# modify /system_data/priv/mms/appinfo.db with the python software given by Y2JB, to prevent youtube to update itself. command: python3 appinfo_editor.py

# Youtube app running app: /mnt/sandbox/PPSA01650_000/download0/cache/splash_screen . Before modifying, make permission of download0 to 777 recursively. And then copy everything in ahR0blablablablabla folder from the autoloader. After that, set splash.html to 444 permission.

# optional: ps5_autoloader folder put in /data
