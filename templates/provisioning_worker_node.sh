#!/bin/sh

# join swarm mode cluster
docker swarm join --advertise-addr ${ip} --token "`cat /mnt/nfs/${fqdn}/.swarm-join-token`" 192.168.100.11:2377
