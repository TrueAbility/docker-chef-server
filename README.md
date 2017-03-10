# Docker Chef Server

## Docker Compose (Development)

```
$ docker-compose up
```

## Usage

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
```

## Startup Wait Lock

On startup `reconfigure` is always run, unless the container id hasn't change 
(determined by `/var/opt/.container_id`).  During reconfiguration, a lock 
file is created at `/var/opt/opscode/.reconfigure.lock`, and removed once 
complete.

For scripting, it is important to ensure that startup and reconfiguration is 
complete before attempting to access the server.  This can be handled easily 
with the included wait script:

```
$ docker exec -it [CONTAINER_ID] chef-server-wait-lock
```

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
