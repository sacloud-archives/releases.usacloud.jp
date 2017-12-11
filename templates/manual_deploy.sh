#!/bin/sh

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock \
                    -v $PWD:/work \
                    -e BASEDIR="/mnt/nfs/${fqdn}" \
                    -w /work \
                    --entrypoint sh \
                    sacloud/releases-webhook-dockerhub deploy/post-deploy.sh