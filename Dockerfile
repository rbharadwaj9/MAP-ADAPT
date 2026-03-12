FROM ros:noetic-ros-base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN sudo apt update && \
    sudo apt-get install -y python3-catkin-tools git curl

RUN sudo apt-get install -y python3-wstool ros-noetic-cmake-modules protobuf-compiler autoconf

RUN mkdir -p /catkin_ws/src

WORKDIR /catkin_ws

RUN catkin init && \
    catkin config --extend /opt/ros/noetic && \
    catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    catkin config --merge-devel

RUN sudo apt install -y rsync libtool

WORKDIR /catkin_ws/src

RUN mkdir MAP-ADAPT

COPY dep_https.rosinstall ./MAP-ADAPT

# SSH
RUN wstool init . ./MAP-ADAPT/dep_https.rosinstall && \
    wstool update

RUN sudo apt install -y ros-noetic-tf ros-noetic-eigen-conversions ros-noetic-tf-conversions ros-noetic-rviz qtbase5-dev ros-noetic-cv-bridge

RUN apt install -y locales && \
    locale-gen en_US.UTF-8

# Preconfigure keyboard
RUN echo "keyboard-configuration  keyboard-configuration/layoutcode  select  us" | debconf-set-selections && \
    echo "keyboard-configuration  keyboard-configuration/layout  select  English (US)" | debconf-set-selections && \
    echo "keyboard-configuration  keyboard-configuration/variant  select  English (US)" | debconf-set-selections && \
    echo "keyboard-configuration  keyboard-configuration/modelcode  select  pc105" | debconf-set-selections && \
    echo "keyboard-configuration  keyboard-configuration/model  select  Generic 105-key PC (intl.)" | debconf-set-selections
ENV DEBIAN_FRONTEND=noninteractive
RUN sudo apt install -y ros-noetic-pcl-conversions
ENV DEBIAN_FRONTEND=noninteractive
RUN sudo apt install -y ros-noetic-pcl-ros

WORKDIR /catkin_ws
RUN rosdep update && rosdep install --from-paths src --ignore-src -r -y

RUN rm -rf /var/lib/apt/lists/*

COPY . ./src/MAP-ADAPT

CMD sleep infinity
#
# RUN catkin build map_adapt_ros && \
#     source ../devel/setup.bash
