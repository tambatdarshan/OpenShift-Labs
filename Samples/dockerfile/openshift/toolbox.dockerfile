FROM registry.access.redhat.com/ubi8/ubi:8.6
RUN dnf install -y iputils net-tools iproute bind-utils tcpdump httpd procps-ng mysql
EXPOSE 80
CMD sleep infinity