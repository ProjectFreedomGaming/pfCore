# pfCore

[![GPL-v3.0](https://img.shields.io/github/license/ProjectFreedomGaming/pfCore)](https://spdx.org/licenses/GPL-3.0-or-later.html) [![Phase](https://img.shields.io/badge/phase-research-green)](https://projectfreedom.io) [![Latest Version](https://img.shields.io/github/v/tag/ProjectFreedomGaming/pfCore)](https://github.com/ProjectFreedomGaming/pfCore/tags)
  
The Analog Pocket **pfx-1** core for [Project Freedom](https://projectfreedom.io).

### Building the core

Building the **pfx-1** core require compiling the bitstream, reversing it, converting some art assets and bundling together all this with the definitions files into a single zip file using a certain file structure and naming convention. Most of this is handled automatically by the included `Makefile` apart from one step: compiling the bitstream.

For the time being, compiling a bitstream for the **Analog Pocket** requires using a closed-source proprietary tool named **Quartus Lite** from **Intel** which is only available on **Windows** or **Linux**. It also requires some headers which contain proprietary **Intel** intellectual property.

Since those cannot be re-licensed here under the **GPL-V3** license, building the **pfx-1** bitstream requires a parallel development environment which take care of compiling the bitstream.

Therefore, we split the process into 3 phases. **Updating** the core-dev source files, **compiling** the bitstream and then **building** the core file.

### Updating the core-dev source files

- Clone the [dev repo](https://github.com/ProjectFreedomGaming/pocket-core-dev.git) needed to compile the bitstream. This is based off the basic core template provided by **Analog**.

- Set the environment variable `PF_POCKET_CORE_DEV_DIR` to point to the folder where the **core-dev** repo is cloned.

- Update the **Verilog** source files inside that repo with the ones used by the **pfx-1** core:
```
make update
```

### Compiling the bitstream

Depending on your setup, this may need to be done on a separate **Windows** or **Linux** machine, which has access to the folder where the **core-dev** repo is cloned.

- Install [Intel Quartus Lite](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime/resource.html) and make sure you choose device support for **Cyclone V** during installation.

- Launch the **Quartus Prime** IDE and select `File->Open Project`. Point it to the file `src/fpga/ap_core.qpf` inside the **core-dev** repo.

- Compile the project and wait for it to complete. It can take a while...

- You should now have an updated bitstream file in `src/fpga/output_files/ap_core.rbf`.

### Packing the core file

Back on the machine where this repo is located, you will need to install a few dependencies used during the packing process.

Install a [supported](docs/Installing%20Python.md) version of **Python** and then install some dependencies:
```
pip install Pillow
```

Then build the **pfx-1** core file:
```
make
```

This will build the **pfx-1** core file into the `_build` folder. If you want the core file to be built somewhere else you can set the `PF_CORE_RELEASE_FOLDER` environment variable.

### Other make targets

You can also clean the project using:
```
make clean
```

### Installing the core on the Analog Pocket

Once you have the **pfx-1** core built, you can install it using the `pfInstallCore` command. It takes two argument: the name of the core zip file and the path to the volume where your **SD** card is mounted (either directly or via the **Pocket**'s USB disk mode). For example:
```
pfInstallCore _build/ProjectFreedom.pfx1-0.0.1-2023-03-13.zip /Volumes/MYSDCARD
```

This will copy all the core files in the rigth locations on the SD card.

### Other commands

There are some other commends provided, mostly used by other scripts:

- `pfConvertImage` - Convert an image for to the binary format used by the **Analog Pocket** for its cores and platform lists.

- `pfReverseBitstream` - Converts an `rbf` bitstream file into an `rbd_r` reversed bitstream.

### License

**pfCore** is distributed under the terms of the [GPLv3.0](https://spdx.org/licenses/GPL-3.0-or-later.html) or later license.
