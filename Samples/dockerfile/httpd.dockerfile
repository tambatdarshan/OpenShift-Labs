FROM registry.access.redhat.com/ubi8/ubi:8.5
RUN dnf install -y iputils net-tools iproute bind-utils tcpdump httpd procps-ng
RUN echo "helloworld" > /var/www/html/index.html
EXPOSE 80
ENTRYPOINT /usr/sbin/httpd -DFOREGROUND