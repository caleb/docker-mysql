FROM mysql:5.7

ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

# Install modules
RUN chmod +x /usr/local/bin/mo

COPY helpers /helpers
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mysqld"]
