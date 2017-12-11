#!/bin/sh

sleep 30

# setup nfs-area directories
sudo mkdir -p /mnt/nfs/${fqdn}
sudo mkdir -p /mnt/nfs/${fqdn}/versions
sudo mkdir -p /mnt/nfs/${fqdn}/certs
sudo mkdir -p /mnt/nfs/${fqdn}/deploy
sudo mkdir -p /mnt/nfs/${fqdn}/logs

# write .htpasswd
docker run -it --rm sacloud/htpasswd ${user_name} ${password} > .htpasswd 2> /dev/null
sudo mv .htpasswd /mnt/nfs/${fqdn}/

# init swarm mode
docker swarm init --advertise-addr 192.168.100.11 --listen-addr 192.168.100.11:2377

docker swarm join-token -q worker > .swarm-join-token
sudo mv .swarm-join-token /mnt/nfs/${fqdn}/

echo -n "${fqdn}" > fqdn
sudo mv fqdn /mnt/nfs/${fqdn}/

sudo mv /home/rancher/manual_deploy.sh /mnt/nfs/${fqdn}/
sudo chmod +x /mnt/nfs/${fqdn}/manual_deploy.sh

# write yaml to build docker-stack
cat > post-deploy.sh << 'EOL'
${build_docker_stack}
EOL
sudo mv post-deploy.sh /mnt/nfs/${fqdn}/deploy/
sudo chmod +x /mnt/nfs/${fqdn}/deploy/post-deploy.sh

# enable webhook service
sudo ros service enable /var/lib/rancher/conf/webhook-dockerhub.yml
sudo ros service up webhook-dockerhub
