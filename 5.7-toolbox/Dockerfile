FROM mysql:5.7

ADD https://github.com/caleb/docker-helpers/archive/master.tar.gz /tmp/helpers.tar.gz
ADD https://raw.githubusercontent.com/caleb/mo/master/mo /usr/local/bin/mo

# Install modules
RUN mkdir -p /helpers \
&& tar xzf /tmp/helpers.tar.gz --strip-components=1 -C / docker-helpers-master/helpers \
&& rm /tmp/helpers.tar.gz \
&& chmod +x /usr/local/bin/mo

COPY helpers /helpers
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["initialize"]
