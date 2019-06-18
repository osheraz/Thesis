#  Thesis AUTONOMOUS Loader

## Description
The repository contain arm control files for project number 19-20 including:
* arm_control - ROS package.
* matlab direct and inverse kinematics.
* arduino pwn,dir publisher files.

<p align="center">
  <img src="https://i.ibb.co/wRcBjgg/k4.jpg" width="350"/>
</p>

## Simulation

## Configuration
The control commands for the loader needs to be published via the joints topic.
### komodo2:
1. linear_velocity {-1 : 1} 
1. angular_velocity {-1 : 1}
### arm mechanisem:
1. arm {-0.5 : 0.5} 
1. bucket {-0.5 : 0.5}

## TODO
* improve control via simulation in gazebo
* add pile of sand recognition
* add force\torque sensor to the bucket.
* add demos for specific situations.


## Contacts
The repository is maintained by Osher Azulay , osheraz@post.bgu.ac.il.<br />

