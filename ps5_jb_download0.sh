#!/bin/bash

# This jailbreak enables autoloader by uploading download0.dat to /user/download/PPSA01650 to update Youtube app with autoloader files.
# The process of uploading download0.dat via FTP is slow (compared to ps5_jb_autoload.sh), but simple to implement.

# This jailbreak does:
# 1) Prerequisite: Install the modified Youtube app by restoring console from Y2JB backup.
# 2) Modify /system_data/priv/mms/appinfo.db with the python software given by Y2JB, to prevent youtube to update itself.
# 3) Upload download0.dat to /user/download/PPSA01650 to update Youtube app with autoloader files.
# 4) Create ps5_autoloader folder in /data with autoload.txt and etaHEN.bin.

# Restore console from Y2JB.
zenity --info --text="Do the following:\n1) Please restore your console with Y2JB provided backup that contains the modified YouTube app.\n2) Connect to the wireless network manually, with DNS is set to 62.210.38.117.\n3) Open the YouTube App and then click OK." --title="PS5 Jailbreak Initialization."

# PS5 essentials
WORK_DIR="/media/dave/20T_MAIN/Primary/proyek/220901 PS5/251020 Jailbreak/WORKDIR_NODELETE"
AUTOLOAD_FILE="$WORK_DIR/autoload.txt"
GIT_Y2JB_REPO="$WORK_DIR/github-Y2JB"
HEN_URL="https://github.com/etaHEN/etaHEN/releases/download/2.3B/etaHEN-2.3B.bin"
DOWNLOAD0_URL="https://github.com/itsPLK/ps5_y2jb_autoloader/releases/download/v0.3/download0.dat"


# PS5 FTP folders
PS5_IP="192.168.14.158"
PS5_FTP_PORT=1337
PS5_EXPLOIT_PORT=50000
PS5_HEN_PORT=9021

# Derived folders
HEN_FILE="$WORK_DIR/$(basename "$HEN_URL")"
DOWNLOAD0_FILE="$WORK_DIR/$(basename "$DOWNLOAD0_URL")"

# Send the lapse exploit payload
python3 "$GIT_Y2JB_REPO/payload_sender.py" "$PS5_IP" "$PS5_EXPLOIT_PORT" "$GIT_Y2JB_REPO/payloads/lapse.js"

# Wait for a few seconds to ensure the exploit is processed
sleep 5

# Send the HEN payload
python3 "$GIT_Y2JB_REPO/payload_sender.py" "$PS5_IP" "$PS5_HEN_PORT" "$HEN_FILE"

# Get a pop up to inform the user that the initialization is complete.
zenity --info --text="Wait until etaHEN is loaded (it will report IP, FTP, and KLog).\nAnd then click OK." --title="PS5 Jailbreak Initialized"

# Copy /system_data/priv/mms/appinfo.db from FTP to local to prevent YouTube from updating itself.
# Copy appinfo.db from PS5 via FTP
echo "Modifying appinfo.db..."
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

# if download0.dat does not exist in $WORK_DIR, download https://github.com/itsPLK/ps5_y2jb_autoloader/releases/download/v0.3/download0.dat
# then upload it to PS5 /user/download/PPSA01650/download0.dat
if [ ! -f "$DOWNLOAD0_FILE" ]; then
    echo "Downloading download0.dat..."
    if wget -O "$DOWNLOAD0_FILE" "$DOWNLOAD0_URL"; then
        echo "download0.dat downloaded successfully."
    else
        echo "Error: Failed to download download0.dat"
        exit 1
    fi
fi      
# Upload download0.dat to PS5
echo "Uploading download0.dat to PS5..."
ftp -n -p "$PS5_IP" "$PS5_FTP_PORT" <<EOF
prompt off
binary
put "$DOWNLOAD0_FILE" /user/download/PPSA01650/download0.dat
quit
EOF
echo "download0.dat uploaded to PS5 successfully."

# download etaHEN-2.3B.bin from https://github.com/etaHEN/etaHEN/releases/download/2.3B/etaHEN-2.3B.bin if it doesn't exist
if [ ! -f "$HEN_FILE" ]; then
    echo "Downloading etaHEN-2.3B.bin..."
    if wget -O "$HEN_FILE" "$HEN_URL"; then
        echo "etaHEN-2.3B.bin downloaded successfully."
    else
        echo "Error: Failed to download etaHEN-2.3B.bin"
        exit 1
    fi
fi

# create ps5_autoloader folder in /data and copy autoload.txt and 251111 etaHEN-2.3B as etaHEN there
echo "Creating ps5_autoloader folder in /data..."
ftp -n -p "$PS5_IP" "$PS5_FTP_PORT" <<EOF
prompt off
binary
mkdir /data/ps5_autoloader
put "$AUTOLOAD_FILE" /data/ps5_autoloader/autoload.txt
put "$HEN_FILE" /data/ps5_autoloader/etaHEN.bin
quit
EOF
echo "ps5_autoloader folder created in /data successfully."

# Get a pop up to inform the user that the jailbreak setup is complete
zenity --info --text="PS5 Jailbreak setup is now complete!\nRESTART your console NOW." --title="Jailbreak Complete"
