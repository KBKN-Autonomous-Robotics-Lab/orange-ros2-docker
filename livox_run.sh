# Check if a container name is provided or not
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
    --device /dev/ZLAC8015D:/dev/ZLAC8015D:mwr \
    --device /dev/sensors/estop:/dev/sensors/estop:mwr \
    --device /dev/input/js0:/dev/input/js0:mwr \
    --device /dev/sensors/CLAS:/dev/sensors/CLAS:mwr \
    --device /dev/sensors/GNSSbase:/dev/sensors/GNSSbase:mwr \
    --device /dev/sensors/GNSSrover:/dev/sensors/GNSSrover:mwr \
    kbkn202x/orange_ros2:latest
	
#   -e RESOLUTION=1920x1080
#   js0;DualSense Controller
#   js1;DualSense trackpad
#   -p 6080:80
#   -p 2222:22
#   -p 10940:10940
#   -p 2368:2368/udp
#   -p 8308:8308/udp
#   -p 56000:56000/udp
#   --device /dev/ZLAC8015D:/dev/ZLAC8015D:mwr
#   --device /dev/sensors/estop:/dev/sensors/estop:mwr
#   --device /dev/input/js0:/dev/input/js0:mwr
#   --device /dev/sensors/CLAS:/dev/sensors/CLAS:mwr
#   --device /dev/sensors/GNSSbase:/dev/sensors/GNSSbase:mwr
#   --device /dev/sensors/GNSSrover:/dev/sensors/GNSSrover:mwr
#   --device /dev/sensors/imu:/dev/sensors/imu:mwr
#   --device /dev/sensors/hokuyo_urg:/dev/sensors/hokuyo_urg:mwr
#   --device /dev/ttyUSB0:/dev/ttyUSB0:mwr

