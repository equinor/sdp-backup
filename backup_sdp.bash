#!/usr/bin/env bash
# Usage
# backup_sdp.bash --file=targets.csv --destination=/data/backup
#
#INPUT
#This script is designed to use a .CSV-file as input. The file must use "," as a separator, and
#have the following columns;
#<computername>,<alternative computername>,<IP>,
#<"/folder/to/copy" "/second/folder/to/copy">,</folder/to/exclude /second/folder/to/exclude>
#
#Prerequistes
#Backup server being able to SSH to the targeted servers(as password less root)
#
#Not implemented(21.11.2017):
#User named 'backuper' on all involved systems. Must be able to read Targeted files, and write to Destination
#Recommended to use ACL
#example: setfacl -R -m u:backuper:r <backupfolder>

#Set script location as working directory
PATH=$PATH:/bin/rsync
set -e
cd "${0%/*}"

# Argument parsing structure
for i in "$@"
do
case $i in
    -f=*|--file=*)
    INPUT_CSV=$(cut -d '=' -f 2 <<< $i)
    shift
    ;;

    -d=*|--destination=*)
    DESTINATION=$(cut -d '=' -f 2 <<< $i)
    shift
    ;;

esac
done

# Set defaul
if [ -z  $INPUT_CSV ]; then
    INPUT_CSV='targets.csv'
fi

# Set default backup location
if [ -z $DESTINATION ]; then
    DESTINATION='/data/backup'
fi

if [ ! -f $INPUT_CSV ]; then
    echo "Can't find $INPUT_CSV...exiting"
    exit 1
fi

echo "Input file is: $INPUT_CSV"
echo "Backup destination is: $DESTINATION"

# Iterate through the input .csv file and perform rsync backup.
# May want to do this in parallel.
minTEST=0

IFS=';'
while read COMPUTERNAME ALT_HOSTNAME IP DIR EXCLUDE
do

    echo $minTEST
    minTEST=$((minTEST+1))

    #Create path for computername in target dir
    CNAME_PATH=$DESTINATION/$ALT_HOSTNAME/
    if [ ! -d $CNAME_PATH ]; then
        mkdir -v $CNAME_PATH
    fi

    IFS=' ' read -r -a EXCLUDELIST <<< "$EXCLUDE"
    for i in "${EXCLUDELIST[@]}"
    do
        ROPTION+=("--exclude=$i")
    done

    echo "rsync -av ${ROPTION[@]} root@$COMPUTERNAME:$DIR $CNAME_PATH"
    /usr/bin/rsync -av \
    ${ROPTION[@]} \
    root@$COMPUTERNAME:$DIR \
    $CNAME_PATH

    ROPTION=()
    EXCLUDELIST=()

done < $INPUT_CSV

exit 0