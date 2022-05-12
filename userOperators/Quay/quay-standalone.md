# Standalone Quay

## Installation

~~~bash
$ sudo yum install -y podman conmon
$ sudo podman login registry.redhat.io
Username: <username>
Password: <password>
$ firewall-cmd --permanent --add-port=80/tcp
$ firewall-cmd --permanent --add-port=443/tcp
$ firewall-cmd --permanent --add-port=5432/tcp
$ firewall-cmd --permanent --add-port=5433/tcp
$ firewall-cmd --permanent --add-port=6379/tcp
$ firewall-cmd --reload
~~~

## Start postgres

~~~bash
$ mkdir -p $QUAY/postgres-quay
$ setfacl -m u:26:-wx $QUAY/postgres-quay

$ sudo podman run -d --rm --name postgresql-quay \
  -e POSTGRESQL_USER=quayuser \
  -e POSTGRESQL_PASSWORD=quaypass \
  -e POSTGRESQL_DATABASE=quay \
  -e POSTGRESQL_ADMIN_PASSWORD=adminpass \
  -p 5432:5432 \
  -v /root/quay/postgres-quay:/var/lib/pgsql/data:Z \
  registry.redhat.io/rhel8/postgresql-10:1
~~~

## Start Quay

~~~bash
$ podman run -d --rm -p 80:8080 -p 443:8443     --name=quay    -v /root/quay/config:/conf/stack:Z    -v /root/quay/storage:/datastorage:Z    registry.redhat.io/quay/quay-rhel8:v3.5.7
~~~