FROM ubuntu:jammy-20230522

ARG TARGETPLATFORM
LABEL maintainer="Alpaca-zip<zip.lottestr@gmail.com>"

SHELL ["/bin/bash", "-c"]

# Upgrade OS
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Install Ubuntu Mate desktop
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ubuntu-mate-desktop && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Add Package
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        tigervnc-standalone-server tigervnc-common \
        supervisor wget curl gosu git sudo python3-pip tini \
        build-essential vim sudo lsb-release locales \
        bash-completion tzdata terminator && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# noVNC and Websockify
RUN git clone https://github.com/AtsushiSaito/noVNC.git -b add_clipboard_support /usr/lib/novnc
RUN pip install git+https://github.com/novnc/websockify.git@v0.10.0
RUN ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html

# Set remote resize function enabled by default
RUN sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" /usr/lib/novnc/app/ui.js

# Disable auto update and crash report
RUN sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades
RUN sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# Enable apt-get completion
RUN rm /etc/apt/apt.conf.d/docker-clean

# Install ROS
ENV ROS_DISTRO humble
# desktop or ros-base
ARG INSTALL_PACKAGE=desktop

RUN apt-get update -q && \
    apt-get install -y curl gnupg2 lsb-release && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update -q && \
    apt-get install -y ros-${ROS_DISTRO}-${INSTALL_PACKAGE} \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    python3-pip \
    python3-testresources \
    python3-wstool \
    gedit && \
    rosdep init && \
    rm -rf /var/lib/apt/lists/*

RUN rosdep update

# Install simulation package only on amd64
# Not ready for arm64 for now (July 28th, 2020)
# https://github.com/Tiryoh/docker-ros2-desktop-vnc/pull/56#issuecomment-1196359860
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    apt-get update -q && \
    apt-get install -y \
    ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-ros-ign && \
    rm -rf /var/lib/apt/lists/*; \
    fi

# Install orange_ros2 python dependencies
RUN python3 -m pip install --user --upgrade --no-cache-dir --no-warn-script-location pip && \
    python3 -m pip install --user --upgrade --no-cache-dir --no-warn-script-location setuptools==58.2.0 && \
    python3 -m pip install --user --upgrade --no-cache-dir --no-warn-script-location pymodbus==3.2.2

# Create 'ubuntu' user and set up ros2_ws directory
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
    echo "ubuntu:ubuntu" | /usr/sbin/chpasswd 2> /dev/null && \
    mkdir -p /home/ubuntu/ros2_ws/src && \
    chown -R ubuntu:ubuntu /home

# Clone and build orange_ros2 package as 'ubuntu' user
USER ubuntu
WORKDIR /home/ubuntu/ros2_ws/src
RUN git clone https://github.com/KBKN-Autonomous-Robotics-Lab/orange_ros2.git && \
    wstool init . && \
    wstool merge orange_ros2/orange_ros2.rosinstall && \
    wstool update

# Switch to 'root' user for rosdep install
USER root
RUN apt-get update && \
    rosdep update && \
    rosdep install -r -y -i --from-paths /home/ubuntu/ros2_ws/src --rosdistro=${ROS_DISTRO} && \
    rm -rf /var/lib/apt/lists/*

# Build
USER ubuntu
WORKDIR /home/ubuntu/ros2_ws
RUN /bin/bash -c "source /opt/ros/humble/setup.bash; colcon build"

# Update .bashrc with custom aliases
RUN echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc && \
    echo "alias cm='cd ~/ros2_ws;colcon build'" >> ~/.bashrc && \
    echo "alias cs='cd ~/ros2_ws/src'" >> ~/.bashrc && \
    echo "alias cw='cd ~/ros2_ws'" >> ~/.bashrc

# Switch back to 'root' user
USER root
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "-c", "/entrypoint.sh" ]

ENV USER ubuntu
ENV PASSWD ubuntu
