#!/bin/bash

# This jailbreak enables autoloader by modifying sandbox folder with autoloader files.
# The whole process is faster (compared to uploading download0.dat) due to direct modification of the sandbox folder.
# However, it requires more steps to implement and clicking through the YouTube app 2 times at specific timing.

# This jailbreak does:
# 1) Prerequisite: install the modified Youtube app by restoring console from Y2JB backup. Jailbreak the console with manual steps
# 2) Modify /system_data/priv/mms/appinfo.db with the python software given by Y2JB, to prevent youtube to update itself.
# 3) Modify /mnt/sandbox/PPSA01650_000/download0/cache/splash_screen/aHR0cHM6Ly93d3cueW91dHViZS5jb20vdHY=/ with the contents from the autoloader.
# 4) Copy ps5_autoloader folder to /mnt/sandbox/PPSA01650_000/download0/cache/splash_screen/aHR0cHM6Ly93d3cueW91dHViZS5jb20vdHY=/ps5_autoloader

# Restore console from Y2JB.
zenity --info --text="Do the following:\n1) Please restore your console with Y2JB provided backup that contains the modified YouTube app.\n2) Connect to the wireless network manually, with DNS is set to 62.210.38.117.\n3) Open the YouTube App and then click OK." --title="PS5 Jailbreak Initialization."

# PS5 essentials
WORK_DIR="/media/dave/20T_MAIN/Primary/proyek/220901 PS5/251020 Jailbreak/WORKDIR_NODELETE"
AUTOLOAD_FILE="$WORK_DIR/autoload.txt"
GIT_Y2JB_REPO="$WORK_DIR/github-Y2JB"
GIT_AUTOLOADER_REPO="$WORK_DIR/github-ps5_y2jb_autoloader"
HEN_URL="https://github.com/etaHEN/etaHEN/releases/download/2.3B/etaHEN-2.3B.bin"

# PS5 FTP folders
PS5_IP="192.168.14.158"
PS5_FTP_PORT=1337
PS5_EXPLOIT_PORT=50000
PS5_HEN_PORT=9021
PS5_YT_SANDBOX_DIR="/mnt/sandbox/PPSA01650_000"
MOD_DIR_PATH="download0/cache/splash_screen/aHR0cHM6Ly93d3cueW91dHViZS5jb20vdHY="

# Derived folders
PS5_YT_MOD_DIR="$PS5_YT_SANDBOX_DIR/$MOD_DIR_PATH"
LOCAL_APP_DIR="$GIT_AUTOLOADER_REPO/$MOD_DIR_PATH"
HEN_FILE="$WORK_DIR/$(basename "$HEN_URL")"

# Download etaHEN if not already present
if [ ! -f "$HEN_FILE" ]; then
    echo "Downloading etaHEN payload..."
    wget -O "$HEN_FILE" "$HEN_URL"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download etaHEN payload."
        exit 1
    fi
fi

# Send the lapse exploit payload
python3 "$GIT_Y2JB_REPO/payload_sender.py" "$PS5_IP" "$PS5_EXPLOIT_PORT" "$GIT_Y2JB_REPO/payloads/lapse.js"
# Wait for a few seconds to ensure the exploit is processed
sleep 5
# Send the HEN payload
python3 "$GIT_Y2JB_REPO/payload_sender.py" "$PS5_IP" "$PS5_HEN_PORT" "$HEN_FILE"
# Get a pop up to inform the user that the initialization is complete.
zenity --info --text="Wait until etaHEN is loaded (it will report IP, FTP, and KLog).\nAnd then open the YouTube app again to enable sandbox to be modified. And then click OK." --title="PS5 Jailbreak Initialized"

# copy /system_data/priv/mms/appinfo.db from FTP to local
# Copy appinfo.db from PS5 via FTP
ftp -n -p "$PS5_IP" $PS5_FTP_PORT <<EOF
prompt off
binary
get /system_data/priv/mms/appinfo.db "$GIT_Y2JB_REPO/appinfo.db"
quit
EOF
# Navigate to the appinfo_editor directory and run it
cd "$GIT_Y2JB_REPO"
python3 appinfo_editor.py
cd -
# Copy the modified appinfo.db back to the PS5 via FTP
ftp -n -p "$PS5_IP" "$PS5_FTP_PORT" <<EOF
prompt off
binary
put "$GIT_Y2JB_REPO/appinfo.db" /system_data/priv/mms/appinfo.db
quit
EOF

# FTP into PS5 to change permissions and upload modified files
# Youtube app running app: /mnt/sandbox/PPSA01650_000/download0/cache/splash_screen.
# Before modifying, make permission of download0 to 777 recursively.
# And then copy everything in PS5_YT_MOD_DIR folder from the autoloader.
# After that, set splash.html to 444 permission.

echo "Uploading files to PS5..."
if ! ftp -n -p "$PS5_IP" "$PS5_FTP_PORT" <<EOF
prompt off
binary
quote SITE CHMOD 777 $PS5_YT_SANDBOX_DIR/download0
quote SITE CHMOD 777 $PS5_YT_MOD_DIR/splash.html
cd $PS5_YT_MOD_DIR
lcd "$LOCAL_APP_DIR"
mdelete *
mput *
mkdir ps5_autoloader
put "$HEN_FILE" ps5_autoloader/etaHEN.bin
put "$AUTOLOAD_FILE" ps5_autoloader/autoload.txt
quit
EOF
then
    echo "Error: FTP upload failed. Check your PS5 connection and try again."
    exit 1
fi

echo "Setting final permissions..."
ftp -n -p "$PS5_IP" "$PS5_FTP_PORT" <<EOF
quote SITE CHMOD 444 $PS5_YT_MOD_DIR/splash.html
quit
EOF

# Get a pop up to inform the user that the jailbreak setup is complete
zenity --info --text="PS5 Jailbreak setup is now complete!\n\nThe autoloader has been installed and configured.\nYou can now use your jailbroken PS5." --title="Jailbreak Complete"
