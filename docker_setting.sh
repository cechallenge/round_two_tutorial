#!/bin/sh
image_name='nvcr.io/nvidia/pytorch:23.05-py3'
container_name='CE'
WORKSPACE=$HOME

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
               -u root $image_name /bin/bash -c \
               "groupadd -g `id -g` $(whoami); groupadd -rg 109 render; \
                usermod -aG render,video,sudo root; \
                echo '$(whoami) ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers; \
                echo \"$(whoami) soft nofile \`ulimit -n\`\" >> /etc/security/limits.conf; \
                echo \"export http_proxy=$http_proxy\" >> /etc/environment; \
                echo \"export https_proxy=$https_proxy\" >> /etc/environment; \
                echo \"export HTTP_PROXY=$HTTP_PROXY\" >> /etc/environment; \
                echo \"export HTTPS_PROXY=$HTTPS_PROXY\" >> /etc/environment; /bin/bash"

else
    docker start  ${container_name} && docker attach ${container_name}
fi
