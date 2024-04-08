# Linux from Docker (LFD)

This repository contains tooling based on the "Linux from Scratch" (LFS) guide,
available at https://www.linuxfromscratch.org/lfs/view/stable/ .

Rather than using an existing Linux system as-is, this repository demonstrates
how to use docker containers (or, any Dockerfile-compatible OCI tooling, really)
to bootstrap an entirely new Linux system.

This repository uses https://github.com/hairyhenderson/gomplate to render templates.

This repository is designed for three main purposes:

1. Education - Using this tool, anyone with a bit of knowledge of containers and a machine
   with docker (or a compatible builder) can walk through the process of building an entire
   linux system, including those who for various reasons must use Windows, by way of Docker
   Desktop, without any need for extra hardware, patitions, or any risk to their existing
   system.
2. Producing Container Images - This tool can be used to produce highly customized,
   self-hosted images, built entirely from source.
3. Producing Virtual Machine Images - Instead of producing a container image filesystem
   as the final stage, that filesystem can then be mounted into an additional stage that
   then uses virtualization tools produce a complete volume image, complete with bootloader,
   which can be used by any hypervisor software without need to run installer CD's.

## Utility Scripts

### `build.sh`

Build a docker image according to the current state of `config.yaml`, or the file pointed to by the `LFD_CONFIG` variable, if set.

Use `DOCKER_FLAGS` to add additional flags to the `docker build` command.

### `run.sh` `[command...]`

Build a docker image according to the current configuration, then immediately start a new container with it, run the
supplied command, then remove the container when it exits.

Use `DOCKER_RUN_FLAGS` to add additional flags to the `docker run` command.

If no command is specified, defaults to `/bin/sh` with `-it` added to the `docker run` flags.

### `export.sh` `image_id` `path`

Export the contents of the specified image rooted at the specified path. For safely, the path must not exist.

### `build-and-export.sh` `path`

Build and then immediately export an image based on the current config to a path.

### 

## Design

The build process is separated into six stages:

### Stage 0

This stage uses a base image to produce a "host system" (in the example, based on ubuntu 22),
with the necessary tools to build gcc and the other tools necessary for compiling linux itself.

### Stage 1

This stage uses the stage 0 host system to compile a compiler (GCC), linker, assembler, and C/C++
environment.

### Stage 2

This stage uses the tools from stage 1 to re-compile themselves into "self-hosted" versions, along
with packages needed for a minimal linux system, such as a shell (bash), make, coreutils (cp, mv, ln),
etc.

This stage concludes by using a scratch container to build a fresh rootfs with these tools, achieving
the same result as "chroot" in the official linux-from-scratch manual.

### Stage 3

This stage uses the fresh rootfs to continue compiling the remaining tools for a useful linux
system, such as perl, python, and a few tools needed to compile the linux kernel.

### Stage 4

This stage uses the expanded system from stage 3 to compile a customizable set of packages according to
the processes provided by the linux-from-scratch project, notably:

* The Linux kernel
* A bootloader (GRUB)
* An init system (sysvinit)
* The same tools compiled before, including the compiler, linker, and assembler, now fully "self-hosted"
* Networking tools and libraries like iproute and OpenSSL
* Further build tools such as GNU Automake and GDB

This stage concludes by taking all packages built during this stage, and creating one final fresh rootfs
with them.

This stage is where the majority of customization takes place, as from here, "technically", every package
is optional (aside from packages required by other selected packages).

### Stage 5

If desired, this final stage uses a supermin QEMU "Appliance" (VM) to create a disk image with a one partition for the rootfs,
and a second for the GRUB bootloader, and then compresses this disk image using QEMU's qcow2 format.

This stage then concludes in a state that can be used as a Kubevirt containerDisk, or by exporting using the provided script
to use the disk image directly in any compatible virtualization software.

## Configuration Format

Configuration consists of three sections: host, packages, and stages.

The following variables are used throughout the process:

* `LFS_SRC` - The directory to store extracted source archives and patches as well as utility scripts
* `LFS` - The directory to store outputs of builds

### host.image

This is the base image used to build the host system used to compile GCC for the first time.

### host.steps

This should be a string containing a Dockerfile stage (minus FROM) that prepares the `host.image`
to be ready to compile GCC

### packages

Each package is either a source archive or a patch file.

Packages can be "virtual", in which case, they actually refer to another package for their source.
"Virtual" packages allow for the same source archive to be built multiple ways during the process.

Each package is downloaded to a subdirectory of `LFS_SRC` named the same as the package, and all
build commands are executed within this directory.

Build instructions for a packaged are temporarily mounted into the container at `$LFS_SRC/build.sh`
from the host direcotory `util/install-<package>.sh`

Virtual packages use a symlink to point to the source directory downloaded by the "real" package.

### packages[n].name

For a given source archive or patch, this is the name that will be used to refer to it in other
packages and stages

### packages[n].url

For a given package, this is the URL to download the source archive from, or for a patch, the URL
to download the patch file from.

For virtual packages, this field should not be set.

### packages[n].srcFrom

For virtual packages, this is the name of the package that actually contains the source to be
built.
For non-virtual packages, this field should not be set.

### packages[n].lfsDeps

These packages will have their output copied to this package's output prior to building.

This should generally only be used during the host and boostrapping phases, normal packages
should use deps and srcDeps instead.

This field is optional.

### packages[n].srcDeps

These packages will have their extracted source archives copied prior to this package being built.

This should be used when this package intends to build these other packages from source as part
of itself.

This field is optional.

### packages[n].deps

These packages will have their outputs copied to the root filesystem prior to building.

This should be used when this package requires binaries, libraries, headers, or other output data
from these packages.

This field is optional.

### packages[n].patches

The patches downloaded by the packages named in this field will be applied, in this order, prior
to building.

This field is optional.

### packages[n].preBuildSteps

This string should contain any dockerfile steps that must be run prior to building, after all
dependencies have been copied.

This field is optional.

## stages

These define the "stages" of the build. While these are not 1-to-1 with Dockerfile stages, each
of these does start a new Dockerfile stage.

### stages[n].name

The name of the stage, which can be referred to by other stages

### stages[n].parent

The name of the parent stage, "host" to start from the host system, "scratch" to start a completely
blank filesystem (which can be used to perform an equivalent operation to chroot), or an arbitrary
image reference.

### stages[n].lfsInstall

A list of packages built by previous stages that should have their `LFS` directories copied to
`LFS` in this stage, similar to `packages[n].lfsDeps`. 

This should generally only be used during the bootstrapping process, typical stages should use
`install` instead.

This field is optional.

### stages[n].install

A list of packages built by previous stages that should have their `LFS` directories copied to the root of this stage.

This field is optional.

### stages[n].preSteps

This string should contain any Dockerfile steps that should run before building packages.

This field is optional.

### stages[n].packages

A list of package names that should be built by this stage. Each of these begins its own Dockerfile
stage which has the stage's Dockerfile stage as its `FROM`.

Each package may only appear in one stage. Use virtual packages if a package needs to be built
in multiple stages.

This field is optional.
