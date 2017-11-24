# Generates a csv-file from running containers on the nodes specified in the docker-nodes.txt.
# The CSV-file is intended to be used as input for the backup_sdp.bash script.
with open('docker-nodes.txt') as nodefile:
    nodes = nodefile.readlines()
print nodes