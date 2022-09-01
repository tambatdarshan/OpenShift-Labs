# Mirror-registry

## Download mirror-registry binary

<https://console.redhat.com/openshift/downloads#tool-mirror-registry>

## Install mirror-registry

~~~bash

$ ./mirror-registry install --quayHostname quay-server.nancyge.com --quayRoot /var/mirror-registry --initPassword <password>

# The URL will be https://quay-server.nancyge.com:8443
# The credential is init:<password>
# The rootCA is under /var/mirror-registry/quay-rootCA

~~~

## Add Quay's rootCA to OpenShift image for Build

~~~bash

$ oc create configmap registry-cas -n openshift-config --from-file=quay-server.nancyge.com..8443=/tmp/rootCA.pem
$ oc patch image.config.openshift.io/cluster --patch '{"spec":{"additionalTrustedCA":{"name":"registry-cas"}}}' --type=merge

~~~

## Create Secret which Contains Quay Credential

~~~bash

$ cat /tmp/config.json
{
        "auths": {
                "quay-server.nancyge.com:8443": {
                        "auth": "aW5pdDpyZWXXXXXXXX"
                }
        }
}

$ oc create secret generic dockerhub --from-file=.dockerconfigjson=/tmp/config.json --type=kubernetes.io/dockerconfigjson

~~~


## Edit BuildConfig to use your own Quay

~~~bash

$ oc edit bc <BuildConfig>

spec:
  failedBuildsHistoryLimit: 5
  nodeSelector: null
  output:
    pushSecret:
      name: dockerhub
    to:
      kind: DockerImage
      name: quay-server.nancyge.com:8443/rhn_support_cchen/test-s2i:latest

~~~
