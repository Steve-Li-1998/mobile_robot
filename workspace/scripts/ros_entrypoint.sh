#!/usr/bin/env bash
set -e

USER_HOME="/home/${ROS_USERNAME:-ros}"
WORKSPACE_DIR="${USER_HOME}/workspace"

mkdir -p "${WORKSPACE_DIR}/src"

if [ ! -f "${WORKSPACE_DIR}/install/setup.bash" ]; then
  cd "${WORKSPACE_DIR}"
  colcon build
fi

if [ -f /opt/ros/humble/setup.bash ]; then
  # Ensure ROS environment is available for direct commands.
  . /opt/ros/humble/setup.bash
fi

if [ -f "${WORKSPACE_DIR}/install/setup.bash" ]; then
  . "${WORKSPACE_DIR}/install/setup.bash"
fi

if [ "$#" -gt 0 ]; then
  exec "$@"
fi

exec bash
