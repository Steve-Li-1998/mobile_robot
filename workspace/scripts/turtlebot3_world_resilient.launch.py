#!/usr/bin/env python3

import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, TimerAction
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    pkg_tb3_gazebo = get_package_share_directory('turtlebot3_gazebo')
    pkg_gazebo_ros = get_package_share_directory('gazebo_ros')

    use_sim_time = LaunchConfiguration('use_sim_time', default='true')
    x_pose = LaunchConfiguration('x_pose', default='-2.0')
    y_pose = LaunchConfiguration('y_pose', default='-0.5')
    spawn_timeout = LaunchConfiguration('spawn_timeout', default='180.0')
    spawn_delay = LaunchConfiguration('spawn_delay', default='6.0')

    world = os.path.join(pkg_tb3_gazebo, 'worlds', 'turtlebot3_world.world')

    gzserver_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(pkg_gazebo_ros, 'launch', 'gzserver.launch.py')
        ),
        launch_arguments={
            'world': world,
            'verbose': 'false'
        }.items()
    )

    gzclient_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(pkg_gazebo_ros, 'launch', 'gzclient.launch.py')
        )
    )

    robot_state_publisher_cmd = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(pkg_tb3_gazebo, 'launch', 'robot_state_publisher.launch.py')
        ),
        launch_arguments={'use_sim_time': use_sim_time}.items()
    )

    turtlebot_model = os.environ.get('TURTLEBOT3_MODEL', 'waffle')
    model_sdf = os.path.join(
        pkg_tb3_gazebo,
        'models',
        f'turtlebot3_{turtlebot_model}',
        'model.sdf'
    )

    spawn_turtlebot_cmd = Node(
        package='gazebo_ros',
        executable='spawn_entity.py',
        arguments=[
            '-entity', turtlebot_model,
            '-file', model_sdf,
            '-x', x_pose,
            '-y', y_pose,
            '-z', '0.01',
            '-timeout', spawn_timeout,
        ],
        output='screen',
    )

    delayed_spawn_cmd = TimerAction(
        period=spawn_delay,
        actions=[spawn_turtlebot_cmd]
    )

    return LaunchDescription([
        DeclareLaunchArgument('use_sim_time', default_value='true'),
        DeclareLaunchArgument('x_pose', default_value='-2.0'),
        DeclareLaunchArgument('y_pose', default_value='-0.5'),
        DeclareLaunchArgument('spawn_timeout', default_value='180.0'),
        DeclareLaunchArgument('spawn_delay', default_value='6.0'),
        gzserver_cmd,
        gzclient_cmd,
        robot_state_publisher_cmd,
        delayed_spawn_cmd,
    ])
