# oc-mirror

## Installation

<https://github.com/openshift/oc-mirror>

~~~bash
$ git clone https://github.com/openshift/oc-mirror.git
$ cd oc-mirror
$ make build
~~~

## List Channels

~~~bash
$ for i in odf-operator mcg-operator odf-csi-addons-operator; do ./bin/oc-mirror list operators --version=4.10 --catalog=registry.redhat.io/redhat/redhat-operator-index:v4.10 --package=$i; done
~~~

## Sync the Image

~~~bash
$ ./bin/oc-mirror --config /tmp/imageset.yaml docker://bastion.ocp4.example.com:5000/oc-mirror
~~~
