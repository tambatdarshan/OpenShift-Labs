FROM registry.access.redhat.com/ubi8/ubi:8.5
RUN dnf install -y iputils net-tools iproute bind-utils tcpdump httpd procps-ng
EXPOSE 80
CMD sleep infinity