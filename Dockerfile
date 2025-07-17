FROM osrf/ros:humble-desktop

ARG USER_NAME=user
ARG USER_UID=1000
ARG USER_GID=1000
ARG INSTALL_TYPE=desktop

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

RUN apt update -y && apt install -y sudo

RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /workspace && \
    chown ${USER_UID}:${USER_GID} /workspace
    
USER ${USER_NAME}
WORKDIR /workspace

# Locales (UTF-8)
RUN sudo -E apt update -y && sudo -E apt install -y locales
RUN sudo locale-gen en_US en_US.UTF-8
RUN sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

RUN sudo apt update && \
    sudo apt install -y ros-${ROS_DISTRO}-ros-gz && \
    sudo apt install -y lsb-release gnupg && \
    sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    sudo apt update && \
    sudo apt install -y ignition-fortress

RUN sudo apt -y install wget gcc make cmake

RUN git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git && \
    cd Micro-XRCE-DDS-Agent && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j6 && \
    sudo make install -j6 && \
    sudo ldconfig /usr/local/lib/ && \
    cd .. && \
    rm -rf Micro-XRCE-DDS-Agent

# RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive && \
#     bash ./PX4-Autopilot/Tools/setup/ubuntu.sh