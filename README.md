# docker-base

On the demographics team we work with code on an HPC cluster, our local computer, and on continuous integration (CI) servers like Github Actions or Jenkins.
These all can have different operating systems, file structures available, packages installed etc. that make it difficult to reliably be able to run the same code on these different computing environments and get the code to work and/or produce the same results.

Containers help to get code and software to run on different computing environments and [Docker](https://www.docker.com/) has become the most popular container software.

This docker image contains almost all of the GBD demographics team's packages and software dependencies.
There is an internal private image [docker-internal](https://github.com/ihmeuw-demographics/docker-internal) that includes still private packages and filepaths.
The eventual goal is to move all dependencies to this publicly available image [docker-base] and get rid of [docker-internal].

# How to run the container

## Install Docker

Follow the directions [here](https://docs.docker.com/get-started/#set-up-your-docker-environment) to install docker for Mac or Windows.

## How to run the container on a local machine

Before running the container the user needs to know the tag (version) of the image they want to use. How images are versioned is documented on the [wiki](https://github.com/ihmeuw-demographics/docker-base/wiki/How-the-docker-image-is-versioned-and-pushed-to-Docker-Hub#tag-versioning-system).
A list of available tags is available on [Github](https://github.com/ihmeuw-demographics/docker-base/releases) or on [Docker Hub](https://hub.docker.com/r/ihmeuwdemographics/base/tags).

The following command tells docker to pull the ihmeuwdemographics/base image from [DockerHub](https://hub.docker.com/r/rocker/geospatial) with the tag `v{gbd_year}.{release_number}.{patch}`.
This launches an Rstudio-Server session that is then accessible at the specified port http://localhost:8787.
The default username and password is 'rstudio' and shouldn't need to be changed.

```
docker run --rm -p 8787:8787 ihmeuwdemographics/base:v{gbd_year}.{release_number}.{patch}
```

If the default username and password 'rstudio' isn't working than try specifying a different password when running the container with the `-e PASSWORD={mypassword}` option

### Interacting with the local filesystem

One thing new users will notice is that the docker container is isolated from the users filesystem, so the user can't access locally available files and can't save new files. 
[Volumes](https://docs.docker.com/storage/volumes/) are used to connect a directory on the host machine to a directory in the container.

All one needs to do is add an option to the `docker run` command.

```
-v {path_on_host_machine}:{path_in_container}
```

Now files available at `{path_on_host_machine}` are available at {path_in_container} and vice versa.

# More information

## External Resources

If you are familiar with R and Rstudio this [tutorial](http://ropenscilabs.github.io/r-docker-tutorial/) is a very helpful quick introduction to Docker from an R developer perspective. 

A more general [getting started page](https://docs.docker.com/get-started/) is available from Docker.

## How to make changes to the image

See the [wiki page](https://github.com/ihmeuw-demographics/docker-base/wiki/How-to-make-changes-to-the-image).

## How the image is versioned and deployed

See the [wiki page](https://github.com/ihmeuw-demographics/docker-base/wiki/How-the-docker-image-is-versioned-and-pushed-to-Docker-Hub)

