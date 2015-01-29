FROM mysql:5.7

ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

# Install modules
RUN chmod +x /usr/local/bin/mo

COPY docker-entrypoint.sh /setup.sh

CMD ["/setup.sh", "mysqld"]
