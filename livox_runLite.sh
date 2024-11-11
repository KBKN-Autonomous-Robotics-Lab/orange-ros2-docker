# Check if a name container is provided or not
if [ -z "$1" ]; then
    echo "Error: You must specify the container name as the first argument."
    exit 1
fi

CONTAINER_NAME=$1

sudo docker run \
    --name "$CONTAINER_NAME" \
    --ipc host \
    --net host \
    --shm-size=512m \
    --security-opt seccomp=unconfined \
    kbkn202x/orange_ros2:latest

#
#   -e RESOLUTION=1920x1080
#   -p 6080:80
#   -p 2222:22
#   -p 10940:10940
#   -p 2368:2368/udp
#   -p 8308:8308/udp
#   -p 56000:56000/udp
#   --device /dev/webcam:/dev/webcam:mwr \
#   --device /dev/ZLAC8015D:/dev/ZLAC8015D:mwr \
#   --device /dev/webcam2:/dev/webcam2:mwr \
