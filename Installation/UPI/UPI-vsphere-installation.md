# VSPhere UPI Installation

## Create Manifests

~~~bash

$ openshift-install create manifests --dir=install

$ cat <<EOF > install/manifests/cluster-network-03-config.yml
apiVersion: operator.openshift.io/v1
kind: Network
metadata:
  name: cluster
spec:
  defaultNetwork:
    openshiftSDNConfig:
      vxlanPort: 4800
EOF

$ rm -f install/openshift/99_openshift-cluster-api_master-machines-*.yaml openshift/99_openshift-cluster-api_worker-machineset-*.yaml

~~~

## Generate Ignition Files

~~~bash

$ openshift-install create ignition-configs --dir=install

~~~

## Generate base64 Ignition Files

~~~bash

$ cat <<EOF > install/merge-bootstrap.ign

{
  "ignition": {
    "config": {
      "merge": [
        {
          "source": "http://10.72.94.224/openshift/bootstrap.ign",
          "verification": {}
        }
      ]
    },
    "timeouts": {},
    "version": "3.1.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {},
  "systemd": {}
}

EOF

$ base64 -w0 install/master.ign > install/master.64
$ base64 -w0 install/worker.ign > install/worker.64
$ base64 -w0 install/merge-bootstrap.ign > install/merge-bootstrap.64

$ cp install/bootstrap.ign /var/www/html/openshift/

~~~

## Create VM in VSphere

1. Download ISO from <https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/>
2. Deploy OVA File to a template
3. Clone template to Virtual Machine - bootstrap, master-[0-2], worker-[0-1]

## Install govc Tool

~~~bash

$ curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | tar -C /usr/local/bin -xvzf - govc

$ export GOVC_URL=vmware.rhts.gsslab.pek2.redhat.com
$ export GOVC_USERNAME=administrator@vsphere.local
$ export GOVC_PASSWORD=<OpenShift>
$ export GOVC_DATACENTER=OpenShift
$ export GOVC_INSECURE=true

~~~

## Inject guestinfo to Nodes

~~~bash

MASTER_IGN=`cat install/master.64`
WORKER_IGN=`cat install/worker.64`
BOOTSTRAP_IGN=`cat install/merge-bootstrap.64`

# Bootstrap
#IPCFG="ip=10.72.94.248::10.72.94.254:255.255.255.0:::none nameserver=10.72.44.184"
IPCFG="ip=10.72.94.248::10.72.94.254:255.255.255.0:::none nameserver=10.72.17.5"
govc vm.change -vm bootstrap -e "guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
govc vm.change -vm bootstrap -e "guestinfo.ignition.config.data=${BOOTSTRAP_IGN}"
govc vm.change -vm bootstrap -e "guestinfo.ignition.config.data.encoding=base64"
govc vm.change -vm bootstrap -e "disk.EnableUUID=TRUE"

# Master
$ for i in 0 1 2
do
#IPCFG="ip=10.72.94.23$i::10.72.94.254:255.255.255.0:::none nameserver=10.72.44.184"
IPCFG="ip=10.72.94.23$i::10.72.94.254:255.255.255.0:::none nameserver=10.72.17.5"
govc vm.change -vm master-$i -e "guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
govc vm.change -vm master-$i -e "guestinfo.ignition.config.data=${MASTER_IGN}"
govc vm.change -vm master-$i -e "guestinfo.ignition.config.data.encoding=base64"
govc vm.change -vm master-$i -e "disk.EnableUUID=TRUE"
done

# Worker
$ for i in 0 1
do
#IPCFG="ip=10.72.94.24$i::10.72.94.254:255.255.255.0:::none nameserver=10.72.44.184"
IPCFG="ip=10.72.94.23$i::10.72.94.254:255.255.255.0:::none nameserver=10.72.17.5"
govc vm.change -vm worker-$i -e "guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
govc vm.change -vm worker-$i -e "guestinfo.ignition.config.data=${WORKER_IGN}"
govc vm.change -vm worker-$i -e "guestinfo.ignition.config.data.encoding=base64"
govc vm.change -vm worker-$i -e "disk.EnableUUID=TRUE"
done

~~~
