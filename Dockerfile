FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Basic OS packages and locale setup
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    curl \
    gnupg2 \
    lsb-release \
    ca-certificates \
    software-properties-common \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=1000

# Add ROS 2 apt repository
RUN mkdir -p /etc/apt/keyrings \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /etc/apt/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo ${UBUNTU_CODENAME}) main" \
    > /etc/apt/sources.list.d/ros2.list

# Install ROS 2 Humble desktop
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    ros-humble-turtlebot3-description \
    ros-humble-turtlebot3-gazebo \
    ros-humble-nav* \
    ros-humble-cartographer* \
    && rm -rf /var/lib/apt/lists/*

# Install ROS development tools.
# Prefer ros-dev-tools if available; otherwise install common equivalents.
RUN apt-get update && (apt-get install -y --no-install-recommends ros-dev-tools || apt-get install -y --no-install-recommends \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    git) \
    && rosdep init || true \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for daily development usage
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && mkdir -p /home/${USERNAME}/workspace \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Auto-source ROS environment in interactive shells
RUN echo "source /opt/ros/humble/setup.bash" >> /home/${USERNAME}/.bashrc \
    && echo "if [ -f /home/${USERNAME}/workspace/install/setup.bash ]; then source /home/${USERNAME}/workspace/install/setup.bash; fi" >> /home/${USERNAME}/.bashrc

WORKDIR /home/${USERNAME}/workspace
USER ${USERNAME}

CMD ["bash"]
