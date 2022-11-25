# Install OpenShift on OpenStack IPI

## Pre Install Configuration

1. Download rc file from webconsole Project -> API Access -> Download OpenStack RC File
2. Create Floating IPs for API and Ingress

    ~~~bash

    $ openstack floating ip create --description "api.multi-osp.cchen.work" provider_net_shared_3
    $ openstack floating ip create --description "apps.multi-osp.cchen.work" provider_net_shared_3
    $ openstack floating ip list --long -c 'Floating IP Address' -c Description
    +---------------------+-----------------------------------+
    | Floating IP Address | Description                       |
    +---------------------+-----------------------------------+
    | 10.0.111.112        | api.multi-osp.cchen.work          |
    | 10.0.109.186        | apps.multi-osp.cchen.work         |
    +---------------------+-----------------------------------+

    $ openstack floating ip set --tag reserve 10.0.111.112
    $ openstack floating ip set --tag reserve 10.0.109.186

    ~~~

3. Create Security Group

    ~~~bash

    $ openstack security group list -c ID -c Name -c Description
    +--------------------------------------+------------------------+--------------------------------+
    | ID                                   | Name                   | Description                    |
    +--------------------------------------+------------------------+--------------------------------+
    | 604df802-aa38-4cd2-a65d-9af8484f91b5 | OCP                    | allow 6443 443 80 22           |
    | 7ba1187e-4433-4eba-9a81-29ef3dcf190a | all rules              | all rules                      |
    | b029f012-294f-431f-9f95-cf94eac90743 | ssh                    |                                |
    | e18ec1e0-3227-4de1-9cc2-e050928249e3 | default                | Default security group         |
    +--------------------------------------+------------------------+--------------------------------+
    ~~~

4. Confirm Available Flavors

    ~~~bash

    $ openshift flavor list

    ~~~

## Fill in the install-config.yaml

~~~bash

$ cat files/install-config.yaml
apiVersion: v1
baseDomain: cchen.work
controlPlane:
  name: master
  platform:
    openstack:
      type: ocp-master-large
      additionalSecurityGroupIDs:
      - 604df802-aa38-4cd2-a65d-9af8484f91b5 # OCP Security Group
  replicas: 3
compute:
- name: worker
  platform:
    openstack:
      type: ocp-master-large
      additionalSecurityGroupIDs:
      - 604df802-aa38-4cd2-a65d-9af8484f91b5 # OCP Security Group
  replicas: 2
metadata:
  name: multi-osp
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 192.168.0.0/24 # Need to change from 10.0.0.0/16 due to overlapped subnet of RH lab
  serviceNetwork:
  - 172.30.0.0/16
  networkType: OVNKubernetes
platform:
  openstack:
    cloud: psi
    externalNetwork: provider_net_shared_3 # Pre-configured external Network
    computeFlavor: ocp-master-large
    apiFloatingIP: 10.0.111.112            # API Floating IP we created before
    ingressFloatingIP: 10.0.109.186        # Ingress Floating IP we created before

~~~

## Launch the Installation

~~~bash

$ mkdir install
$ cp install-config.yaml install
$ ./openshift-install create cluster --dir=install
INFO Credentials loaded from file "/Users/cchen/.config/openstack/clouds.yaml"
INFO Consuming Install Config from target directory
INFO Obtaining RHCOS image file from 'https://rhcos.mirror.openshift.com/art/storage/releases/rhcos-4.11/411.86.202210041459-0/x86_64/rhcos-411.86.202210041459-0-openstack.x86_64.qcow2.gz?sha256=b00c23ccfbff9491bb95a74449af6d6a367727b142bb9447157dd03c895a0e9f'
INFO The file was found in cache: /Users/cchen/Library/Caches/openshift-installer/image_cache/rhcos-411.86.202210041459-0-openstack.x86_64.qcow2. Reusing...
INFO Creating infrastructure resources...
INFO Waiting up to 20m0s (until 10:34AM) for the Kubernetes API at https://api.multi-osp.cchen.work:6443...
INFO API v1.24.6+5157800 up
INFO Waiting up to 30m0s (until 10:46AM) for bootstrapping to complete...
~~~
