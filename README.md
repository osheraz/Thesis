#  Thesis AUTONOMOUS Loader

## Description
The repository contain 

<p align="center">
  <img src="https://i.ibb.co/wRcBjgg/k4.jpg" width="350"/>
</p>

## TODO
* improve loading sand, maybe change grains model.
* improve sand spilling visualization.
* start working on bobby-sand forces.
* start working on wheels/tracks-surface forces.
* add demos for specific situations.

## Configuration
The control commands for the bobcat are to be published in `controlCMD` topic in robot's namespace.
The message consists of the following fields (included types/range of values received from `joy_listener`):
1. linear_velocity {-0.05 : 0.05} **Higher values will make the robot misbehave!!!**
1. angular_velocity {-0.5 : 0.5}
1. hydraulics_velocity {-1 : 1}
1. loader_velocity {-1 : 1}
1. brackets_velocity {-1 : 1}
1. spawn_sand {bool}
1. clear_workplace {bool}
1. pause {bool}
1. reset {bool}
Boolean values published continuously will lead to repeated action.



## Contacts
The repository is maintained by Osher Azulay , osheraz@post.bgu.ac.il.<br />

