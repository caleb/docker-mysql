FROM mysql:5.5

MAINTAINER Caleb Land <caleb@land.fm>

ENV DOCKER_HELPERS_VERSION=1.0

# Download our docker helpers
ADD https://github.com/caleb/docker-helpers/releases/download/v${DOCKER_HELPERS_VERSION}/helpers-v${DOCKER_HELPERS_VERSION}.tar.gz /tmp/helpers.tar.gz

# Install the docker helpers
RUN mkdir -p /helpers \
&&  tar xzf /tmp/helpers.tar.gz -C / \
&&  rm /tmp/helpers.tar.gz

# Install the base system
RUN /bin/bash /helpers/install-base.sh

RUN mv /entrypoint.sh /base-entrypoint.sh
COPY docker-entrypoint.sh /entrypoint.sh
