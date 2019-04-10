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

The idea with this project is that your entire development environment is built as a container. Given this, 
the best way to customize your environment is to customize the [`./Dockerfile`](./Dockerfile) to meet your needs.

## Docker-in-Docker

The Docker container builds a docker client that can be used without conflicting with the host docker instance.

## Persisting Data

When the container is started it will mount a volume to a `/sync` directory in the container and continually sync 
the `/home/<username>` directory which is created with the following sub-directories:

- `~/code-server`: maintains all data, config, extensions, etc for Code-Server
- `~/workspace`: working environment that Code-Server opens initially

When you're ready to stop developing, you can shut down and restart the container without losing data, regardless
of whether or not you're persisting volumes. Simply `docker stop amet-USERNAME` (fill in your username!) when you're
done, and `docker start amet-USERNAME` when you're ready to start again. All your changes from the last run will
be waiting for you.

