# Generates a csv-file from running containers on the nodes specified in the docker-nodes.txt.
# The CSV-file is intended to be used as input for the backup_sdp.bash script.
import subprocess
import sys
import json
import csv

with open('docker-nodes.txt') as nodefile:
    nodes = nodefile.readlines()
print nodes


def ssh(HOST,COMMAND):
    ssh = subprocess.Popen(["ssh", "%s" % HOST, COMMAND],
                           shell=False,
                           stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
    result = ssh.stdout.readlines()
    if result == []:
        error = ssh.stderr.readlines()
        print >> sys.stderr, "ERROR: %s" % error
    else:
        return result


user="root@"
for node in nodes:
    HOST = user+node
    COMMAND = "docker ps --format={{.Names}}"
    containers = ssh(HOST,COMMAND)
    mount_format = ""

    for container in containers:
        #This should work, but does takes ALL mounts, not only binds.
        #COMMAND = "docker inspect --format='{{range .Mounts}};{{.Source}};{{end}}' %s" % (container)
        #volume_mounts = ssh(HOST,COMMAND)
        #volume_mounts = volume_mounts.split(';')
        # for mount in volume_mounts:
        #   mount_format += "'%s' " % (mount)


        COMMAND = "docker inspect --format '{{json .Mounts}}' %s" % (container)
        mounts_json = json.loads(ssh(HOST,COMMAND))

        for mount in mounts_json:
            if mount['Type'] == 'Bind':
                mount_format += "'%s' " % (mount)
            else:
                error = "Skipping volume as it's not a 'bind' type"

    with open('py_targets.csv', 'a') as targetfile:
        targetfile.write('%s;;;%s;') % (node,mount_format)