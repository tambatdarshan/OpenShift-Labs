# Operator SDK for GoLang

## Install packages and download operator-sdk and opm

~~~bash
# I'm using OCP 4.8 so make sure you are using golang 1.16
$ yum install gcc make
~~~

## Initial the operator and create API

~~~bash
$ mkdir memcached-operator
$ cd memcached-operator
$ operator-sdk init --domain=cchen666.github.io --repo=github.com/cchen666/memcached-operator
$ operator-sdk create api --group=cache --version=v1alpha1 --kind=Memcached
~~~

## Change the code api/v1alpha1/memcached_types.go

~~~go
type MemcachedSpec struct {
    // +kubebuilder:validation:Minimum=0
    // Size is the size of the memcached deployment
    Size int32 `json:"size"`
}

type MemcachedStatus struct {
    // Nodes are the names of the memcached pods
    Nodes []string `json:"nodes"`
}

~~~

## Generate and Manifests

~~~bash
$ make generate
$ make manifests
~~~

## Copy files/memacached_controller.go.sample to controllers/memcached_controller.go

~~~bash
$ cp $_PATH/files/memcached_controller.go.sample controllers/memcached_controller.go
$ make manifests
~~~

## Change the Makefile

~~~makefile
IMAGE_TAG_BASE ?= quay.io/rhn_support_cchen/memcached-operator
IMG ?= $(IMAGE_TAG_BASE):latest
~~~

## Build the operator

~~~bash

$ make docker-build
$ make docker-push

~~~

## Build the bundle

~~~bash
$ make bundle
$ make bundle-build
$ make bundle-push
~~~

## Build the CatalogSource

~~~bash
$ make catalog-build
$ make catalog-push
~~~

## Install the CatalogSource

~~~bash

$ oc apply -f files/catalogsource.yaml

~~~

## Check in the webUI

~~~bash
# You see your own Operator and the Operator could be installed
$ oc get pods -n openshift-operators | grep memcached
memcached-operator-controller-manager-548bf664f9-4qt7m   2/2     Running     0          26s
~~~
