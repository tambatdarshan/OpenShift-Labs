FROM registry.access.redhat.com/ubi8/ubi:8.6
RUN dnf install -y iputils net-tools iproute bind-utils tcpdump httpd procps-ng dpdk ethtool
COPY mapping.txt /root
COPY entrypoint.sh .
EXPOSE 80
CMD ./entrypoint.sh