FROM mysql:5.7

ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

RUN chmod +x /usr/local/bin/mo \
 && mv /entrypoint.sh /base-entrypoint.sh

COPY helpers /helpers
COPY docker-entrypoint.sh /entrypoint.sh
