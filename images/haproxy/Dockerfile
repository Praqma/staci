FROM haproxy:1.7
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN mkdir /var/haproxy
RUN chown 1000:1000  -R /var/haproxy
