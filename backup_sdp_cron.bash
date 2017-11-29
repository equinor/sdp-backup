#!/usr/bin/env bash
cd "$(dirname "$0")/SDP-backup"
git pull https://oauth2:jnSNZvui5kGDEwSsZLyy@git.statoil.no/sdp/SDP-backup.git
chmod u+x backup_sdp.bash
./backup_sdp.bash -f=targets.csv