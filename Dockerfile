FROM ubuntu:16.04
EXPOSE 80 443
MAINTAINER TrueAbility Ops <ops@trueability.com>
COPY src/ /src
VOLUME /var/opt
WORKDIR /
RUN /src/bin/build.sh
CMD ["/src/bin/run.sh"]
