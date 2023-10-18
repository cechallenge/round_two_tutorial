#!/bin/sh
image_name='nvcr.io/nvidia/pytorch:23.05-py3'
container_name='CE'
WORKSPACE=$HOME

docker ps -a | grep ${container_name} > /dev/null 2>&1
result=$?

if [ ! $result -eq 0 ]; then
    echo "No Container found, Create new containter ${container_name}"

    mkdir -p $WORKSPACE

    # Start docker images (only once)
    docker run -it --user root --net=host --shm-size 128G \
               --security-opt seccomp:unconfined \
               --cap-add=ALL --privileged \
               -v $WORKSPACE:$WORKSPACE \
               -v /home/:/home/ \
               --name=${container_name} \
               --gpus all \
               $image_name
else
    docker start  ${container_name} && docker attach ${container_name}
fi
