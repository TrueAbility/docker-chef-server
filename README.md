# Docker Chef Server

This project provides a single server implementation of Chef Server as a 
Docker image, and is accessible via 
[Docker Hub](https://hub.docker.com/r/trueability/chef-server/):

```bash
$ docker pull trueability/chef-server
```

Available tags are:

* `latest`
* `X.Y.z`
* `X.Y.z+manage`
* etc.

See [Docker Hub](https://hub.docker.com/r/trueability/chef-server/) for all 
current tags.


## Disclaimer

This project is intended for development/testing purposes where the latest
Chef Server is required.  The version will follow upstream stable where 
possible, and there will be little attempt to maintain any sort of backward 
compatibility.

Please do not rely on this image for production!


## Usage

**Docker Compose**

```bash
$ docker-compose up
```

The container will be named `dockerchefserver_chef-server_1` which is 
annoying, but via `docker-compose` you can call it as `chef-server`:

```bash
# manage container with chef-server-ctl
$ docker-compose exec chef-server chef-server-ctl ...

# or drop into bash
$ docker-compose exec chef-server /bin/bash
```

**Docker Directly**

```bash
$ docker run -it \
    --name chef-server \
    -v /path/to/data:/var/opt \
    -p 0.0.0.0:80:80 \
    -p 0.0.0.0:443:443 \
    --privileged \
    -e EXTERNAL_URL="https://mydomain.example.com" \
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

 * `EXTERNAL_URL` *(hostname)*: Tells Chef Server what the publicly accessible
 URL is.  Default: `https://localhost`.


## Startup Wait Lock

On startup `reconfigure` is always run, unless the container id hasn't change 
(determined by `/var/opt/.run/container_id`).  During startup, a lock 
file is created at `/var/opt/.run/startup.lock`, and removed once 
the startup/reconfigure/etc is complete.

For scripting, it is important to ensure that startup and reconfiguration is 
complete before attempting to access the server.  This can be handled easily 
with the included wait script:

```bash
$ docker exec -it [CONTAINER_ID] chef-server-wait-lock
```

Note that on the first boot, the startup wait lock also does a second wait to
ensure that the `pivotal` user has been created properly before resuming.  
Ultimately, the first boot will take several minutes to complete because of
all the reconfigurations that need to happen.


## Working With Chef Server

The server can be accessed via `docker exec` in order to administer Chef 
Server, the same as you would anywhere else.

```bash
$ docker exec -it [CONTAINER_ID] chef-server-ctl ...
```

Alternatively, you can drop into a BASH shell:

```bash
$ docker exec -it [CONTAINER_ID] /bin/bash

XXXXXXXX $ chef-server-ctl ...
```


## Chef Server Customizations

A sane default `chef-server.rb` is setup read/only in the image under 
`/etc/opscode/chef-server.rb`, but local customizations can be made in the 
file `[DATA]/opscode/etc/chef-server-local.rb`.

See the [Chef Documentation](https://docs.chef.io/config_rb_server.html) for
all configurations that can be made in `chef-server.rb`.


## Caveats

* Chef Server does not like running on alternative ports, and is difficult
  (or impossible?) to run on anything but `:80` and `:443`.  In environments
  where consuming these ports is a no-go, you may wish to put Nginx on the 
  frontend to handle proxying to alternative ports (see the
  `docker-compose.yml` and `nginx/default.conf` for a working example).
* Cher Server does not like running on an alternative URL path such as 
  `/chef`.

Any suggestions on how to better handle this in `chef-server.rb`, please help.


## Alternative Builds

Separate builds can be performed using Docker Builds Args to enable additional
functionality (like `chef-manage`, etc):

```
$ docker build --build-args WITH_MANAGE=1 ...
```


## Acknowledgements

This project is largely based off the initial work of Maciej Pasternacki and
his [3ofcoins/chef-server](https://github.com/3ofcoins/docker-chef-server/)
docker image.
