<h1>
  <a href="#"><img alt="phyzx" src="phyzx.png" width="100%"/></a>
</h1>

<p>
  </a>
  </a>
  <a href="https://github.com/lab-key/phyzx/blob/main/LICENSE" alt="License">
    <img src="https://img.shields.io/github/license/lab-key/phyzx">
  </a>
</p>


# About

This repository contains the Zig bindings and implementations for the MuJoCo C API. Plus a lot of additions to make it a full blown Robot Training Framework.

Zig version 0.15.x

MuJoCo version 3.3.8

https://github.com/user-attachments/assets/df516e11-f744-4ea8-813b-1cb99de78644

Robotic Dog



https://github.com/user-attachments/assets/398d0165-595a-4706-9103-7d2417a66357


2D Self-Learning Agent for playing the snake game being used in a 3D enviroment - using DQNAgentC C framework I am working on. All the code will be here soon!

Working on a self-driving agent that can be loaded by a human & unloads by itself - something like a parking / unloading mode when the target is reached.

#### Why phyzx?

I saw the Jolt physics engine bindings which are called zphysics and I thought what a wasted opportunity. This is trying to be more like the official python bindings & the dm_control python package rather than just a physics engine / MuJoCo wrapper, BTW. 

Due to both C and Zig being very low level / lightweight languages it should make this more accessible to run simulations on CPU-only & lower spec hardware in general! Also more importantely once you actually want to convert the simulation's inputs and outputs into some actual system you can use more or less the same code just redefine things a bit.

## Getting Started

You can call on the phyzx-xyz building block modules directly or redefine them or even the `src/phyzx-api.zig` entirely to expose the functions for your needs & workflow!

You should be able to just:

```
git clone https://github.com/lab-key/phyzx.git
# Everything in the examples directory gets built automatically
zig build
# So you can just
./zig-out/bin/control_arm26 # Or ./zig-out/bin/load_arm26 - Just that until I integrate everything properly...
```

This repository uses my [zmujoco] repository as a git submodule all the files are already fetched & everything is already setup. 
In case you want to setup your own zmujoco / mujoco repositories. Check their `setup.zig` files and after that the phyzx `setup.zig` to have all the files setup. Configure the `build.zig` as you like. 
Configure the paths in `build.zig` files according to the way you configured the projects.

## Current and Future plans / issues - TODO

A lot of potential due to Zig being interoberable with C so I'm not sure if I should maybe even keep it ' mixed and dirty ' a bit and make examples on how to do it yourself or try to keep it pure Zig although that would be kinda redundant as Zig was designed with this feature, as C is an old language so.. 

First of all I'm probably not aware of everything that exists and second reprogramming and wrapping everything properly is just too time consuming. 
Also some of the `A.I.` / `control` stuff I'm testing is using OpenBLAS which you can't build directly with Zig as it uses Fortran for example.. So it's either making a Fortran compiler in Zig - using it as a module ( might not even be possible ), invoking the `make` command which is an external dependency ( maybe making that into a Zig module ) or just having a system-wide install of `OpenBLAS` as a dependency which is what I do internally but I don't have time to test everything everywhere properly there might be versioning issues especially across different OSes and I don't want to have the experimental stuff break something for someone - 'works on my machine' type of thing. But maybe I should make some experimental directory and instructions or a separate `build.zig`? Not sure how to go about everything. I'm definitely open and looking for suggestions a bit but I am trying to do something a bit more complicated and Zig is a new language so yeah it's hard to find existing big projects trying to combine things.. If you have any pointers for me let me know!

I'll see depends on the interest as well. 

0. A proper GUI Editor and things mapped out for it but want more ML integration as well otherwise it won't have the same charm....

1. Examples, Tests plus maybe setup some workflow for experimental stuff?

1.1 Integrate minimize, kinematics & inverse-kinematics ( Zig modules ) properly

2. A nice clean way to integrate or point to C libraries that are not buildable with Zig at all. 

2.1 Adding 3rd party modelfiles

3. All the demos and most things I am internally working on are done very ' dirty ' with direct C interop need to either properly wrap it or reprogram it - possibly start working on the experimental directory..

## Documentation

All the documenatation is in the docs/ directory.

I highly recommend you look at the tests directory as well as it contains a lot of examples as does the [zmujoco] project.

MuJoCo's documentation can be found at [mujoco.readthedocs.io]. Upcoming
features due for the next release can be found in the [changelog] in the
"latest" branch.

## Citation

If you use MuJoCo for published research, please cite:

```
@inproceedings{todorov2012mujoco,
  title={MuJoCo: A physics engine for model-based control},
  author={Todorov, Emanuel and Erez, Tom and Tassa, Yuval},
  booktitle={2012 IEEE/RSJ International Conference on Intelligent Robots and Systems},
  pages={5026--5033},
  year={2012},
  organization={IEEE},
  doi={10.1109/IROS.2012.6386109}
}
```

## License and Disclaimer

Copyright 2021 DeepMind Technologies Limited.

Box collision code ([`engine_collision_box.c`](https://github.com/google-deepmind/mujoco/blob/main/src/engine/engine_collision_box.c))
is Copyright 2016 Svetoslav Kolev.

ReStructuredText documents, images, and videos in the `doc` directory are made
available under the terms of the Creative Commons Attribution 4.0 (CC BY 4.0)
license. You may obtain a copy of the License at
https://creativecommons.org/licenses/by/4.0/legalcode.

Source code is licensed under the Apache License, Version 2.0. You may obtain a
copy of the License at https://www.apache.org/licenses/LICENSE-2.0.

This is not an officially supported Google product.

[zmujoco]: https://github.com/lab-key/zmujoco
[build from source]: https://mujoco.readthedocs.io/en/latest/programming#building-mujoco-from-source
[Getting Started]: https://mujoco.readthedocs.io/en/latest/programming#getting-started
[Unity]: https://unity.com/
[releases page]: https://github.com/google-deepmind/mujoco/releases
[mujoco.readthedocs.io]: https://mujoco.readthedocs.io
[changelog]: https://mujoco.readthedocs.io/en/latest/changelog.html
[Python bindings]: https://mujoco.readthedocs.io/en/stable/python.html#python-bindings
[PyPI]: https://pypi.org/project/mujoco/
