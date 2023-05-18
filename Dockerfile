FROM tiryoh/ros2-desktop-vnc:humble


ENV DEBCONF_NOWARNINGS=yes
ENV DEBIAN_FRONTEND noninteractive
ENV ROS_PYTHON_VERSION 3
ENV ROS_DISTRO=humble
ENV PYTHONPATH="$PYTHONPATH:$HOME/.local/lib/python3.8/site-packages"


SHELL ["/bin/bash", "-c"]


EXPOSE 22 
EXPOSE 10940
EXPOSE 2368/udp
EXPOSE 8308/udp


RUN sed -i 's@archive.ubuntu.com@ftp.jaist.ac.jp/pub/Linux@g' /etc/apt/sources.list


RUN apt-get autoclean -y && \
    apt-get clean all -y && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    build-essential \
    dkms \
    openssh-server && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd && \
    echo 'root:ubuntu' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd 


COPY ./startup.sh /startup.sh

# ^ It is not recommended to edit above this line. 

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    python3-pip \
    python3-testresources \
    python3-wstool \
    gedit && \
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*


RUN python3 -m pip install --user --upgrade --no-cache-dir --no-warn-script-location pip && \
    python3 -m pip install --user --upgrade --no-cache-dir --no-warn-script-location setuptools==58.2.0 && \
    python3 -m pip install --user --upgrade --no-cache-dir --no-warn-script-location pymodbus==3.2.2


RUN apt-get update && \
    apt-get upgrade -y && \
    mkdir -p ~/ros2_ws/src && \
    cd ~/ros2_ws && \
    wstool init src && \
    cd ~/ros2_ws/src && \
    git clone https://github.com/KBKN-Autonomous-Robotics-Lab/orange_ros2.git && \
    wstool merge orange_ros2/orange_ros2.rosinstall && \
    wstool update && \
    rosdep install -r -y -i --from-paths . && \
    /bin/bash -c "source /opt/ros/humble/setup.bash; cd ~/ros2_ws/; colcon build" && \
    chown -R $USER:$USER $HOME && \
    echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc && \
    echo "alias cm='cd ~/ros2_ws;colcon build'" >> ~/.bashrc && \
    echo "alias cs='cd ~/ros2_ws/src'" >> ~/.bashrc && \
    echo "alias cw='cd ~/ros2_ws'" >> ~/.bashrc && \
    apt-get autoclean -y && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*


RUN chown -R $USER:$USER $HOME/.local/ && \
mkdir -p $HOME/.config && \
chown -R $USER:$USER $HOME/.config/
