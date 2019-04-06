# DEVENV

Containerized, portable environment for development.

## Introduction

The concept of this project is to create a development environment that utilizes [Docker](https://www.docker.com) 
and [Code-Server](https://github.com/codercom/code-server) to create a fully functional, browser-based, portable 
development environment.

## Quick Start

Make the script (`run.sh`) executable, then run the script, supplying desired `username` and `password` 
for your development environment.

```bash
chmod +x run.sh
./run.sh -u <username> -p <password> [-s <shell>]
```

_Note: the `<shell>` can be `bash` or `zsh` (default: `bash`)_

After this script completes the editor will be running at `https://<HOST|IP>:3000`. It will prompt 
you for the password you entered when running the script.

## Customizing the Environment

The idea with this project is that your entire development environment is built as a container. Given this, 
the best way to customize your environment is to customize the [`./Dockerfile`](./Dockerfile) to meet your needs.

## Docker-in-Docker

The Docker container builds the docker client, then, when started, the script runs the docker command passing the 
`/var/run/docker.sock` as a volume, allowing utilization of the host's docker instantiation within the container.

## Persisting Data

When the environment starts up it creates a `./dev-env` directory which is mounted as a volume in the 
container. This directory is mounted to the `$HOME` path inside of the container.

The root of this directory is your working home directory and can be treated as such; containing other 
directories, rc's, dot-files, etc. The core directories setup are:

- `~/code-server`: maintains all data, config, extensions, etc for Code-Server
- `~/workspace`: working environment that Code-Server opens initially

Since the home directory is mounted as a volume all work, changes, configurations, etc will be maintained 
in the `./dev-env` directory on the host machine and persist when the container is not running.