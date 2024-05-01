# orange_ros2_docker [![Docker Build Check](https://github.com/KBKN-Autonomous-Robotics-Lab/orange_ros2_docker/actions/workflows/build-check-bot.yaml/badge.svg?event=schedule)](https://github.com/KBKN-Autonomous-Robotics-Lab/orange_ros2_docker/actions/workflows/build-check-bot.yaml)

[![dockeri.co](https://dockerico.blankenship.io/image/kbkn202x/orange_ros2)](https://hub.docker.com/r/kbkn202x/orange_ros2)

orange_ros2: https://github.com/KBKN-Autonomous-Robotics-Lab/orange_ros2  
Distribution: `ROS2 Humble Hawksbill`

<img src="https://github.com/KBKN-Autonomous-Robotics-Lab/orange_ros2_docker/assets/84959376/1e21ca28-5208-4993-91c4-928003c13f5c" width="500px">

## Quick start🚀
```
$ docker pull kbkn202x/orange_ros2:latest
$ docker run -p 6080:80 --shm-size=512m --security-opt seccomp=unconfined kbkn202x/orange_ros2:latest
```

## Build from Dockerfile🔧
```
$ git clone https://github.com/KBKN-Autonomous-Robotics-Lab/orange_ros2_docker.git
$ cd orange_ros2_docker
$ bash build.sh
$ bash runLite.sh
```
Browse http://{IP_ADDRESS_OF_YOUR_PC}:6080/
## Tips👻
- If you are running the Gazebo first time, it could take for a long time.
- Gazebo could show empty or even blank screen after launch. In that case, you need to re-launch orange_gazebo.
