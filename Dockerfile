FROM ubuntu:16.04
EXPOSE 80 443
MAINTAINER TrueAbility Ops <ops@trueability.com>
VOLUME /var/opt
WORKDIR /
ARG WITH_MANAGE=0

### install base system packages
RUN apt-get update -y \
    &&  apt-get install -y --no-install-recommends \
            logrotate \
            vim-nox \
            hardlink \
            wget \
            curl \
            ca-certificates \
            upstart-sysv \
            erlang-base

### install chef server and client packages
COPY /src/bin/install-package.sh /src/bin/
RUN /src/bin/install-package.sh server \
    &&  /src/bin/install-package.sh client

### install options plugins (i.e. --build-arg WITH_MANAGE=1)
COPY /src/bin/install-plugins.sh /src/bin
RUN /src/bin/install-plugins.sh

### copy files in after software setup to preserve docker build cache
COPY src/ /src

RUN mkdir -p /opt/opscode/sv /etc/opscode /etc/chef \
    &&  mv /src/logrotate /opt/opscode/sv/logrotate \
    &&  mv /src/knife.rb /etc/chef/knife.rb \
    &&  mv /src/bin/wait-lock.sh /usr/bin/chef-server-wait-lock \
    &&  mv /src/bin/wait-pivotal.sh /usr/bin/chef-server-wait-pivotal \
    &&  mv /src/chef-server.rb /etc/chef-server.rb \
    &&  mv /src/bin/run.sh /usr/bin/chef-server-docker-run \
    &&  ln -sfv /var/opt/opscode/log /var/log/opscode \
    &&  ln -sfv /opt/opscode/sv/logrotate /opt/opscode/service/logrotate \
    &&  ln -sfv /opt/opscode/embedded/bin/sv /opt/opscode/init/logrotate \
    &&  rm -rf \
            /src \
            /tmp/* \
            /var/tmp/* \
            /var/opt/* \
    &&  apt-get autoremove -y \
    &&  apt-get clean -y

CMD ["/usr/bin/chef-server-docker-run"]
