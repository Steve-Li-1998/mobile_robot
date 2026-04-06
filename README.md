# mobile_robot

ROS 2 Humble + MATLAB container development environment managed by Docker Compose v2.

## Project Structure

- `Dockerfile`: Builds ROS 2 Humble development image.
- `docker-compose.yml`: Starts ROS, Gazebo, RViz, and MATLAB containers.
- `workspace/scripts/ros_entrypoint.sh`: Shared startup script that initializes and sources the ROS workspace.
- `workspace/`: Shared host workspace mounted into both containers at `/workspace`.
- `workspace/src/`: Initialized local ROS 2 workspace source directory.

## What This Setup Does

- Builds a ROS 2 Humble image on Ubuntu 22.04.
- Installs ROS desktop plus development tools (`ros-dev-tools` preferred, fallback packages included).
- Reuses one startup script as a shared `entrypoint`; each ROS service only passes its own command arguments.
- Uses host networking (`network_mode: host`) for ROS-related services to keep ROS communication straightforward.
- Mounts the same `./workspace` directory into ROS and MATLAB containers.
- Runs ROS container as a non-root user configured in `Dockerfile`.

## Prerequisites

- Docker Engine + Docker Compose v2
- Linux host
- For MATLAB container: valid MathWorks license configuration

## Configure Local UID/GID (Recommended)

The MATLAB service is configured to run as:

- `user: "${LOCAL_UID:-1000}:${LOCAL_GID:-1000}"`

To avoid file permission issues in `workspace/`, export your host user/group before startup:

```bash
export LOCAL_UID=$(id -u)
export LOCAL_GID=$(id -g)
```

## MATLAB License

Set your license variable before launching if required:

```bash
export MLM_LICENSE_FILE=27000@your-license-server
```

Or use another value that matches your license method.

## Build and Start

```bash
docker compose up --build -d
```

For GUI apps (Gazebo/RViz), allow local Docker containers to access your X server:

```bash
xhost +local:docker
```

## Open Shells

ROS container:

```bash
docker compose exec ros2_humble bash
```

Gazebo container logs:

```bash
docker compose logs -f gazebo
```

RViz container logs:

```bash
docker compose logs -f rviz
```

MATLAB container:

```bash
docker compose exec matlab bash
```

## Workspace Initialization

This repository already initializes a local ROS 2 workspace skeleton:

- `./workspace`
- `./workspace/src`

After containers are up, you can bootstrap the workspace once:

```bash
docker compose exec ros2_humble bash -lc "cd /workspace && colcon build"
```

Then source the local overlay in a ROS shell:

```bash
source /workspace/install/setup.bash
```

## ROS Communication Notes

ROS-related services use the same ROS settings in Compose:

- `ROS_DOMAIN_ID=0`
- `ROS_LOCALHOST_ONLY=0`
- `RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`

Because these services use host networking, ROS 2 discovery and topic communication should work directly as long as domain IDs match.

## Quick ROS 2 Test

In ROS container terminal A:

```bash
ros2 topic pub /chatter std_msgs/msg/String "{data: hello}" -r 1
```

In ROS container terminal B (or MATLAB container if ROS CLI is available there):

```bash
ros2 topic echo /chatter
```

## Stop Services

```bash
docker compose down
```

**License**

- This project is licensed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE) for the full text.


## Known Notes

- If your host does not have Docker available, Compose commands will fail until Docker is installed and running.
- If files in `workspace/` are owned by an unexpected UID/GID, verify `LOCAL_UID` and `LOCAL_GID` before launching.
