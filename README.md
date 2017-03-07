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

## Acknowledgements

This project is largely based off the initial work of Maciej Pasternacki and
his [3ofcoins/chef-server](https://github.com/3ofcoins/docker-chef-server/)
docker image.
