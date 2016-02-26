#!/bin/sh
set -e

for d in `docker ps | awk '{print $1}' | tail -n +2`; do
    d_name=`docker inspect -f {{.Name}} $d`
    echo "========================================================="
    echo "$d_name ($d) container size:"
    sudo du -d 2 -h /var/lib/docker/aufs | grep `docker inspect -f "{{.Id}}" $d`
    echo "$d_name ($d) volumes:"
    for mount in `docker inspect -f "{{range .Mounts}} {{.Source}}:{{.Destination}}                                                                                                                                                      
    {{end}}" $d`; do
        size=`echo $mount | cut -d':' -f1 | sudo xargs du -d 0 -h`
        mnt=`echo $mount | cut -d':' -f2`
        echo "$size mounted on $mnt"
    done
done
