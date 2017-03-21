# Docker Chef Server

This project provides a single server implementation of Chef Server as a 
Docker image, and is accessible via 
[Docker Hub](https://hub.docker.com/r/trueability/chef-server/):

```
$ docker pull trueability/chef-server
```

Available tags are `latest` and every version of Chef Server that has been 
built for.  I.e. `12.13.0`, etc.  See 
[Docker Hub](https://hub.docker.com/r/trueability/chef-server/) for all 
current tags.

## Disclaimer

This project is intended for development/testing purposes where the latest
Chef Server is required.  The version will follow upstream stable where 
possible, and there will be little attempt to maintain any sort of backward 
compatibility.

Please do not rely on this image for production!


## Usage

**Docker Compose**

```
$ docker-compose up
```

The container will be named `dockerchefserver_chef-server_1` which is 
annoying, but via `docker-compose` you can call it as `chef-server`:

```
# manage container with chef-server-ctl
$ docker-compose exec chef-server chef-server-ctl ...

# or drop into bash
$ docker-compose exec chef-server /bin/bash
```

**Docker Directly**

```
$ docker run -it \
    --name chef-server \
    -v /path/to/data:/var/opt \
    -p 0.0.0.0:80:80 \
    -p 0.0.0.0:443:443 \
    --privileged \
    -e PUBLIC_URL="https://mydomain.example.com" \
    -e ENABLE_CHEF_MANAGE=1 \
    trueability/chef-server

$ docker exec -it chef-server chef-server-ctl ...
```


### Privileged Access

Running with `--privileged` is not strictly required, however without
it you will see several errors related to Chef Server attempting to set 
`sysctl` parameters.  These can safely be ignore, though you will need to 
ensure that the host system has sufficient `kernel.shmmax` and 
`kernel.shmall` values.


### Exposed Ports

Both `http/80` and `https/443` are exposed.  Note that if using the Chef 
Manage interface, HTTPS is strictly enforced.


### Volumes

The volume `/var/opt` is strictly required, and is where all Chef Server data 
is stored for persistence.


### Environment Variables

 * `PUBLIC_URL` *(url)*: Tells Chef Server what the publicly accessible 
 URL is.  Default: `https://127.0.0.1/`.
 
 * `ENABLE_CHEF_MANAGE` *(boolean: 1/0)*: Whether or not to include the Chef 
 Management Interface.  If enable, the Chef Manage plugin will be installed 
 on startup everytime a new container is created.  The reason this is not 
 baked into the image is because it adds an additional `1.1G` to the image 
 size.  Default: `0` (not enabled).


## Startup Wait Lock

On startup `reconfigure` is always run, unless the container id hasn't change 
(determined by `/var/opt/.run/container_id`).  During startup, a lock 
file is created at `/var/opt/.run/startup.lock`, and removed once 
the startup/reconfigure/etc is complete.

For scripting, it is important to ensure that startup and reconfiguration is 
complete before attempting to access the server.  This can be handled easily 
with the included wait script:

```
$ docker exec -it [CONTAINER_ID] chef-server-wait-lock
```

Note that on the first boot, the startup wait lock also does a second wait to
ensure that the `pivotal` user has been created properly before resuming.


## Working With Chef Server

The server can be accessed via `docker exec` in order to administer Chef 
Server, the same as you would anywhere else.

```
$ docker exec -it [CONTAINER_ID] chef-server-ctl ...
```

Alternatively, you can drop into a BASH shell:

```
$ docker exec -it [CONTAINER_ID] /bin/bash

XXXXXXXX $ chef-server-ctl ...
```

## Acknowledgements

This project is largely based off the initial work of Maciej Pasternacki and
his [3ofcoins/chef-server](https://github.com/3ofcoins/docker-chef-server/)
docker image.
