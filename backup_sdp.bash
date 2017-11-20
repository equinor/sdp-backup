#!/usr/bin/env bash
# Usage
# backup_sdp.bash --file=targets.csv --exclude=host01 hos*02 --destination=/data/backup
#
#Prerequistes
#Backup server being able to SSH to the targeted servers
#
# Not enforced:
#User named 'backuper' on all involved systems. Must be able to read Targeted files, and write to Destination
#Recommended to use ACL
# example: setfacl -R -m u:backuper:r <backupfolder>

#Set script location as working directory
cd "${0%/*}"
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

if [ ! -f $INPUT_CSV ]; then
    echo "Can't find $INPUT_CSV...exiting"
    exit 1
fi

# Set defaul
if [ -z  $INPUT_CSV ]; then
    INPUT_CSV='targets.csv'
fi

# Set default backup location
if [ -z $DESTINATION ]; then
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
    #Create path for computername in target dir
    CNAME_PATH=$DESTINATION/$ALT_HOSTNAME/
    #echo "All backup vil skrives til $CNAME_PATH"

    #echo "Will operate with this data: Target: $COMPUTERNAME aka $ALT_HOSTNAME IP: $IP Dir. to backup: $DIR"
    if [ ! -d $CNAME_PATH ]; then
        mkdir -v $CNAME_PATH
    fi

    # Split dirs to backup into /<dir> :/<dir/
    DIR=$(echo "$DIR" | sed 's/:/ :/g')
    echo "Rsyncing $COMPUTERNAME:$DIR down to $CNAME_PATH on local..."
    echo "rsync -av root@$COMPUTERNAME:$DIR $CNAME_PATH ..."
    rsync -av root@$COMPUTERNAME:$DIR $CNAME_PATH
    #Vurder bruk av --update, og en annen bruker en root. etc. 'backuper'


done < $INPUT_CSV

exit 0