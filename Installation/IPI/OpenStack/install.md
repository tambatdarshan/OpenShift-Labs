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
INFO Destroying the bootstrap resources...
INFO Waiting up to 40m0s (until 11:13AM) for the cluster at https://api.multi-osp.cchen.work:6443 to initialize...
INFO Install complete!
INFO To access the cluster as the system:admin user when using 'oc', run
INFO     export KUBECONFIG=/Users/cchen/Code/ocp_install/osp/install/auth/kubeconfig
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.multi-osp.cchen.work
INFO Login to the console with user: "kubeadmin", and password: "XXXXXX-XXXXXX-XXXXXX"
INFO Time elapsed: 1h1m56s
~~~

## Check the Cluster

~~~bash

oc get co
NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE   MESSAGE
authentication                             4.11.14   True        False         False      4m56s
baremetal                                  4.11.14   True        False         False      24m
cloud-controller-manager                   4.11.14   True        False         False      27m
cloud-credential                           4.11.14   True        False         False      28m
cluster-autoscaler                         4.11.14   True        False         False      24m
config-operator                            4.11.14   True        False         False      25m
console                                    4.11.14   True        False         False      9m11s
csi-snapshot-controller                    4.11.14   True        False         False      25m
dns                                        4.11.14   True        False         False      24m
etcd                                       4.11.14   True        False         False      22m
image-registry                             4.11.14   True        False         False      11m
ingress                                    4.11.14   True        False         False      11m
insights                                   4.11.14   True        False         False      18m
kube-apiserver                             4.11.14   True        False         False      20m
kube-controller-manager                    4.11.14   True        False         False      21m
kube-scheduler                             4.11.14   True        False         False      20m
kube-storage-version-migrator              4.11.14   True        False         False      25m
machine-api                                4.11.14   True        False         False      21m
machine-approver                           4.11.14   True        False         False      25m
machine-config                             4.11.14   True        False         False      23m
marketplace                                4.11.14   True        False         False      24m
monitoring                                 4.11.14   True        False         False      9m59s
network                                    4.11.14   True        False         False      24m
node-tuning                                4.11.14   True        False         False      24m
openshift-apiserver                        4.11.14   True        False         False      17m
openshift-controller-manager               4.11.14   True        False         False      20m
openshift-samples                          4.11.14   True        False         False      14m
operator-lifecycle-manager                 4.11.14   True        False         False      25m
operator-lifecycle-manager-catalog         4.11.14   True        False         False      25m
operator-lifecycle-manager-packageserver   4.11.14   True        False         False      18m
service-ca                                 4.11.14   True        False         False      25m
storage                                    4.11.14   True        False         False      19m
~~~

## Tuning

1. Check ETCD Performance

* When Storage backend is Ceph:

    ~~~bash

    $ oc get pods
    NAME                                         READY   STATUS      RESTARTS   AGE
    etcd-guard-multi-osp-dmbjv-master-0          1/1     Running     0          9h
    etcd-guard-multi-osp-dmbjv-master-1          1/1     Running     0          9h
    etcd-guard-multi-osp-dmbjv-master-2          1/1     Running     0          9h
    etcd-multi-osp-dmbjv-master-0                5/5     Running     0          9h
    etcd-multi-osp-dmbjv-master-1                5/5     Running     0          9h
    etcd-multi-osp-dmbjv-master-2                5/5     Running     0          9h
    installer-4-multi-osp-dmbjv-master-0         0/1     Completed   0          9h
    installer-6-multi-osp-dmbjv-master-0         0/1     Completed   0          9h
    installer-6-multi-osp-dmbjv-master-2         0/1     Completed   0          9h
    installer-7-multi-osp-dmbjv-master-0         0/1     Completed   0          9h
    installer-7-multi-osp-dmbjv-master-1         0/1     Completed   0          9h
    installer-7-multi-osp-dmbjv-master-2         0/1     Completed   0          9h
    installer-8-multi-osp-dmbjv-master-0         0/1     Completed   0          9h
    installer-8-multi-osp-dmbjv-master-1         0/1     Completed   0          9h
    installer-8-multi-osp-dmbjv-master-2         0/1     Completed   0          9h
    revision-pruner-7-multi-osp-dmbjv-master-0   0/1     Completed   0          9h
    revision-pruner-7-multi-osp-dmbjv-master-1   0/1     Completed   0          9h
    revision-pruner-7-multi-osp-dmbjv-master-2   0/1     Completed   0          9h
    revision-pruner-8-multi-osp-dmbjv-master-0   0/1     Completed   0          9h
    revision-pruner-8-multi-osp-dmbjv-master-1   0/1     Completed   0          9h
    revision-pruner-8-multi-osp-dmbjv-master-2   0/1     Completed   0          9h

    $ for i in `oc get pods | grep etcd-multi | awk '{print $1}'`; do oc logs $i -c etcd | grep 'took too long' | wc -l; done
    3356
    5344
    5250

    ~~~

* When Storage Backend type is tripleo

    ~~~bash
    oc get pods -n openshift-etcd
    NAME                                         READY   STATUS      RESTARTS   AGE
    etcd-guard-multi-osp-5khjg-master-0          1/1     Running     0          8h
    etcd-guard-multi-osp-5khjg-master-1          1/1     Running     0          8h
    etcd-guard-multi-osp-5khjg-master-2          1/1     Running     0          8h
    etcd-multi-osp-5khjg-master-0                5/5     Running     0          8h
    etcd-multi-osp-5khjg-master-1                5/5     Running     0          7h58m
    etcd-multi-osp-5khjg-master-2                5/5     Running     0          8h
    installer-5-multi-osp-5khjg-master-0         0/1     Completed   0          8h
    installer-5-multi-osp-5khjg-master-1         0/1     Completed   0          8h
    installer-7-multi-osp-5khjg-master-0         0/1     Completed   0          8h
    installer-7-multi-osp-5khjg-master-1         0/1     Completed   0          8h
    installer-7-multi-osp-5khjg-master-2         0/1     Completed   0          8h
    installer-8-multi-osp-5khjg-master-0         0/1     Completed   0          8h
    installer-8-multi-osp-5khjg-master-1         0/1     Completed   0          8h
    installer-8-multi-osp-5khjg-master-2         0/1     Completed   0          8h
    revision-pruner-7-multi-osp-5khjg-master-0   0/1     Completed   0          8h
    revision-pruner-7-multi-osp-5khjg-master-1   0/1     Completed   0          8h
    revision-pruner-7-multi-osp-5khjg-master-2   0/1     Completed   0          8h
    revision-pruner-8-multi-osp-5khjg-master-0   0/1     Completed   0          8h
    revision-pruner-8-multi-osp-5khjg-master-1   0/1     Completed   0          8h
    revision-pruner-8-multi-osp-5khjg-master-2   0/1     Completed   0          8h

    $ for i in `oc get pods | grep etcd-multi | awk '{print $1}'`; do oc logs $i -c etcd | grep 'took too long' | wc -l; done
    2761
    2349
    2881
    ~~~

    Conclusion: Though Ceph is SSD based, the default local volume is better than distributed storage for ETCD.