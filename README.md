# Multi Runtime Development Environment - Bun, Node and Deno

## Disclaimer
There is an `scripts/install.sh` in this repo which can install some runtimes (bun, node, deno etc). so please keep in mind this script may need to be chmmoded to be executable.
e.g.
```bash
chmod +x .devcontainer/scripts/install.sh
```

There is also an optional `setup.sh` script which can be used to install npm and typscript globally. This is optional and can be run if you want to install these tools globally.

## Overview
This project provides a Docker image for a customizable development environment. It is based on the `buildpack-deps` image and includes a variety of essential tools for development.

## Prerequisites
- [Docker](https://www.docker.com/get-started) installed on your machine.

## Build Instructions
Use Visual Studio Code's Remote - Containers extension to use the container as a development environment.

To build the Docker image, run the following command in the directory containing the Dockerfile:

```bash
docker build -t my-dev-container .
```

## Run Instructions
To run the Docker container, run the following command:

```bash
docker run -v $HOME:/home/bensimmersdev my-dev-container
```

