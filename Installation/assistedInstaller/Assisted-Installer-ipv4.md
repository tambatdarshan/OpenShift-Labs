# Install IPv4 Only Cluster using AI SaaS

## Create Cluster

~~~bash

$ aicli create cluster --paramfile files/ipv4.yml mycluster

# We can cannot specify api_vip when creating the cluster now but can only update the cluster later
# Being addressed in https://github.com/openshift/assisted-service/pull/3258

$ aicli update cluster -P api_vip=192.168.123.251 mycluster

~~~

## Download ISO

~~~bash

$ aicli create iso mycluster
$ aicli download iso mycluster

~~~

## Create VMs

~~~bash

$ IMAGE=<downloaded ISO>

$ for i in 0 1 2; do \
virt-install \
-n ocp-master-$i \
--memory 16384 \
--os-variant=fedora-coreos-stable \
--vcpus=4  \
--accelerate  \
--cpu host-passthrough,cache.mode=passthrough  \
--disk path=/home/sno/images/ocp-master-$i.qcow2,size=120  \
--network network=ocp-dev,mac=02:01:00:00:00:6$i \
--cdrom $IMAGE & \
done

~~~

## Launch the Installation

~~~bash

$ aicli start cluster mycluster

~~~
