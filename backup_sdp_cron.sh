#!/usr/bin/env bash
cd ./SDP-backup
git pull https://oauth2:####CHANGEME####@git.statoil.no/sdp/SDP-backup.git
chmod u+x backup_sdp.sh
./backup_sdp.sh