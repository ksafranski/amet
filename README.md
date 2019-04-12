# Amet

Containerized, portable development environment.

## Introduction

The concept of this project is to create a development environment that utilizes [Docker](https://www.docker.com) 
and [Code-Server](https://github.com/codercom/code-server) to create a fully functional, browser-based, portable 
development environment.

## Quick Start

Clone the repo:

```
git clone git@github.com:Fluidbyte/amet.git
```

Run the script, supplying desired `username` and `password` for your development environment.

```shell
./amet.sh -u <username> -p <password> [-s <shell>]
```

_Note: the `<shell>` can be `bash` or `zsh` (default: `bash`)_

After this script completes the editor will be running at `https://<HOST|IP>:3000`. It will prompt 
you for the password you entered when running the script. 

If you would like to access the environment over SSH:

```shell
ssh -p 3022 localhost
```

Just enter the password you specified above.

## Customizing the Environment

The idea with this project is that your entire development environment is built as an ubuntu container. To add in
support for the programming languages you work with, libraries you need, or even to bootstrap your dotfiles, Amet allows
you to specify a customizer script. The script will be run during the build in the Dockerfile, under permissions of the
non-root user. But don't fret, you can `sudo` without a password!

### Example customizer

```shell
#!/bin/bash
set -e  # Break the build if there are any errors in this script
set -x  # Print out each instruction in the build output

USER=$(whoami)

# Install Node.js
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install python and tmux
sudo apt-get install -y tmux python

# Global NPM packages
sudo npm i -g yarn binci

# Take ownership of local caches
sudo chown -R $USER:$USER ~/.config ~/.npm

# Install ripgrep
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb
sudo dpkg -i ripgrep_0.10.0_amd64.deb
rm -f ripgrep_0.10.0_amd64.deb
```

To build with the customizer script, just pass the `-c path/to/customizer.sh` option to `amet.sh`. It doesn't need to be chmodded executable, Amet will take care of it!

## Docker-in-Docker

The Docker container builds a docker client and service which can be used without conflicting with the host docker instance.

## Persisting Data

When the container is started it will mount a volume to a `/sync` directory in the container and continually sync 
the `/home/<username>` directory. This directory will appear in the working directory where the `./amet.sh ...` startup command was run.

Additionally, the following directories will be created (on first run) or synced internally (any subsequent runs):

- `~/code-server`: maintains all data, config, extensions, etc for Code-Server
- `~/workspace`: working environment that Code-Server opens initially

## Troubleshooting

**Getting "error creating aufs mount to ..." when launching containers inside Amet**  
On some systems, docker's default and super-efficient `aufs` storage driver can't be used in docker-in-docker
containers like Amet. Simply re-run `amet.sh` and add the `-f vfs` option. This increases the disk space required
to store docker images and can moderately slow builds and launches, but is highly compatible.

