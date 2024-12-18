# linux-container-env

## Overview
This project provides a Docker image for a customizable development environment. It is based on the `buildpack-deps` image and includes a variety of essential tools for development.

## Prerequisites
- [Docker](https://www.docker.com/get-started) installed on your machine.

## Build Instructions
To build the Docker image, run the following command in the directory containing the Dockerfile:

```bash
docker build -t my-dev-container .
```

## Run Instructions
To run the Docker container, run the following command:

```bash
docker run -v $HOME:/home/bensimmersdev my-dev-container
```
Or use Visual Studio Code's Remote - Containers extension to use the container as a development environment.
