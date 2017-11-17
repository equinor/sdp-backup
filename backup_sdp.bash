#!/usr/bin/env bash
# Usage
# backup_sdp.bash --file targets.csv --exclude host01 hos*02 --destination /data/backup

# Argument parsing structure
for i in "$@"
do
case $i in
    -f=*|--file=*)
    INPUT_CSV=$(cut -d '=' -f 2 <<< $i)
    shift
    ;;

    -e=*|--exlcude=*)
    EXCLUDE_HOSTS=$(cut -d '=' -f 2 <<< $i)
    shift
    ;;

    -d=*|--destination=*)
    DESTINATION=$(cut -d '=' -f 2 <<< $i)
    shift
    ;;

esac
done

if [ ! -f "$INPUT_CSV"]; then
    echo "Can't find specified file...exiting";
    exit 1;
fi

# Set defaul
if [ -z "$INPUT_CSV"]; then
    INPUT_CSV='targets.csv'
fi

# Set default backup location
if [ -z $DESTINATION]; then
    DESTINATION='/data/backup'
fi

echo "Input file is: $INPUT_CSV"
echo "Excluded hosts are: $EXCLUDE_HOSTS"
echo "Backup destination is: $DESTINATION"

# Iterate through the input .csv file and perform rsync backup.
# May want to do this in parallel.

IFS=','
while read COMPUTERNAME ALT_HOSTNAME IP DIR
do

    # Test if hostname matches exclude
    #if ${EXCLUDE_HOSTS}== *$(COMPUTERNAME)*; then
    #    continue
    #fi

    echo "Will operate with this data: ""$COMPUTERNAME" "$ALT_HOSTNAME" "$IP" "$DIR"
    # Split dirs to backup into /<dir> :/<dir/
    DIR=$(echo "$DIR" | sed 's/:/ :/g')
    echo "Rsyncing $COMPUTERNAME:$DIR down to $DESTINATION on local..."
    #rsync -arze ssh root@$COMPUTERNAME:$DIR $DESTINATION/$ALT_HOSTNAME


done < $INPUT_CSV

exit 0