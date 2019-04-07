# DEVENV

Containerized, portable environment for development.

## Introduction

The concept of this project is to create a development environment that utilizes [Docker](https://www.docker.com) 
and [Code-Server](https://github.com/codercom/code-server) to create a fully functional, browser-based, portable 
development environment.

## Quick Start

Run the script, supplying desired `password` for your development environment.

```shell
./run.sh -p <password> [-s <shell>]
```

_Note: the `<shell>` can be `bash` or `zsh` (default: `bash`)_

After this script completes the editor will be running at `https://<HOST|IP>:3000`. It will prompt 
you for the password you entered when running the script. Prefer the command line? Hop right in with:

```shell
ssh -p 3022 localhost
```

Just enter the password you specified above.

## Customizing the Environment

The idea with this project is that your entire development environment is built as a container. Given this, 
the best way to customize your environment is to customize the [`./Dockerfile`](./Dockerfile) to meet your needs.

## Docker-in-Docker

The Docker container builds a docker client that can be used without conflicting with the host docker instance.

## Persisting Data

If you pass the `-l` flag to `run.sh`, it creates a `./dev-env` directory which is mounted as a volume in the 
container. This directory is mounted to the `$HOME` path inside of the container.

The root of this directory is your working home directory and can be treated as such; containing other 
directories, rc's, dot-files, etc. The core directories setup are:

- `~/code-server`: maintains all data, config, extensions, etc for Code-Server
- `~/workspace`: working environment that Code-Server opens initially

Since the home directory is mounted as a volume all work, changes, configurations, etc will be maintained 
in the `./dev-env` directory on the host machine and persist when the container is not running.

Want to persist just certain files and folders, relative to your user's home folder? Pass arguments like
`-m .ssh -m Projects` to the `run.sh` and they'll appear in the same location in the container.

When you're ready to stop developing, you can shut down and restart the container without losing data, regardless
of whether or not you're persisting volumes. Simply `docker stop USERNAME-dev` (fill in your username!) when you're
done, and `docker start USERNAME-dev` when you're ready to start again. All your changes from the last run will
be waiting for you.

