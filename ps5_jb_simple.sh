#!/bin/bash

# This jailbreak is a simple jailbreak script that only sends the Lapse exploit and etaHEN payload to the PS5 via PC, no autoloader.

# This jailbreak does:
# 1) Prerequisite: Install the modified Youtube app by restoring console from Y2JB backup.
# 2) Send Lapse exploit and etaHEN payload to PS5 to enable jailbreak.

# PS5 Jailbreak configuration
WORK_DIR="/media/dave/20T_MAIN/Primary/proyek/220901 PS5/251020 Jailbreak/WORKDIR_NODELETE"
GIT_Y2JB_DIR="$WORK_DIR/github-Y2JB"
HEN_URL="https://github.com/etaHEN/etaHEN/releases/download/2.3B/etaHEN-2.3B.bin"

# PS5 FTP configuration
PS5_IP="192.168.14.158"
PS5_FTP_PORT=1337
PS5_EXPLOIT_PORT=50000
PS5_HEN_PORT=9021

# Derived folders
HEN_FILE="$WORK_DIR/$(basename "$HEN_URL")"

# Send the lapse exploit payload
python3 "$GIT_Y2JB_DIR/payload_sender.py" "$PS5_IP" "$PS5_EXPLOIT_PORT" "$GIT_Y2JB_DIR/payloads/lapse.js"

# Wait for a few seconds to ensure the exploit is processed
sleep 5

# Send the HEN payload
python3 "$GIT_Y2JB_DIR/payload_sender.py" "$PS5_IP" "$PS5_HEN_PORT" "$HEN_FILE"


