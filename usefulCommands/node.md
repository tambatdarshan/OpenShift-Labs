# Node

## Node info

~~~bash
oc adm top node <node>
oc describe node <node> | grep taint

oc whoami --show-console
~~~

## Recreate /etc/kubenetes/manifests

~~~bash
oc patch etcd cluster -p='{"spec": {"forceRedeploymentReason": "recovery-'"$( date --rfc-3339=ns )"'"}}' --type=merge
oc patch kubecontrollermanager cluster -p='{"spec": {"forceRedeploymentReason": "recovery-'"$( date --rfc-3339=ns )"'"}}' --type=merge
oc patch kubescheduler cluster -p='{"spec": {"forceRedeploymentReason": "recovery-'"$( date --rfc-3339=ns )"'"}}' --type=merge
~~~

## Create POD outside the OCP cluster

~~~bash
$ podman run -v $(pwd)/:/kubeconfig -e KUBECONFIG=/kubeconfig/kubeconfig -e LATENCY_TEST_RUN=true -e DICOVERY_MODE=true -e LATENCY_TEST_CPUS=7 -e LATENCY_TEST_RUNTIME=600 -e MAXIMUM_LATENCY=20 -e ROLE_WORKER_CNF=master
-e CLEAN_PERFORMANCE_PROFILE=false
 registry.redhat.io/openshift4/cnf-tests-rhel8:v4.9 /usr/bin/test-run.sh -ginkgo.focus="oslat"

 crictl pull <image>
 podman pull <image> --authfile /var/lib/kubelet/config.json
 $ oc get pods -n performance-addon-operator-testing

perf stat -a -A --smi-cost
podman run --privileged -it -v /:/host --rm --entrypoint bash quay.io/alosadag/troubleshoot:latest

https://github.com/SchSeba/dpdk-testpm-trex-example/blob/main/pods/dpdk/trex/testpmd.yaml#L62

~~~

## Label the node and set NodeSelector

~~~bash
$ oc label nodes worker03.ocp4.example.com env=nginx
$ oc patch deployment/nginx  --patch '{"spec":{"template":{"spec":{"nodeSelector":{"env":"nginx"}}}}}'
~~~

## Some Json tricks

~~~bash

$ oc get deployment console -o jsonpath='{.spec.template.spec.containers[0].image}'
$ oc patch smcp/basic -p='{"spec":{"general":{"logging":{"componentLevels":{"ior":"debug"}}}}}'  --type=merge
$ oc patch smcp basic --type json -p '[{"op": "remove", "path": "/spec/general/logging/componentLevels/ior"}]'
# openshift list all pods and thier specs (requests/limits)
$ oc get pod -o jsonpath='{range .items[*]}{"SPEC:  \n  LIMITS  : "}{.spec.containers[*].resources.limits}{"\n  REQUESTS: "}{.spec.containers[*].resources.requests}{"\n"}{end}'
# openshift list all pods and thier specs with name (requests /limits)
$ oc get pod -o jsonpath='{range .items[*]}{"NAME:  "}{.metadata.name}{"\nSPEC:  \n  LIMITS  : "}{.spec.containers[*].resources.limits}{"\n  REQUESTS: "}{.spec.containers[*].resources.requests}{"\n\n"}{end}'
# openshift list all nodes and thier corresponding os/kernel verion
$ oc get nodes -o jsonpath='{range .items[*]}{"\t"}{.metadata.name}{"\t"}{.status.nodeInfo.osImage}{"\t"}{.status.nodeInfo.kernelVersion}{"\n"}{end}'
# openshift patch build config with patch
$ oc patch bc/kube-ops-view -p '{"spec":{"resources":{"limits":{"cpu":"1","memory":"1024Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}}}'
# openshift display the images used by Replication Controller
$ oc get rc -n openshift-infra -o jsonpath='{range .items[*]}{"RC: "}{.metadata.name}{"\n Image:"}{.spec.template.spec.containers[*].image}{"\n"}{end}'
# openshift display the requestor for namespace
$ oc get namespace ui-test -o template --template '{{ index .metadata.annotations "openshift.io/requester"  }}'
# openshift display all projects and its creator sorted by creator
$ IFS=,; while read data1 data2; do printf "%-60s : %-50s\n" $data1 $data2;
done < <( oc get projects -o template \
--template '{{range .items}}{{.metadata.name}},{{index .metadata.annotations "openshift.io/requester"}}{{"\n"}}{{end }}' |
sort -t, -k2 )
# openshift fetch custom column name from metadata
$ oc get rolebinding -o=custom-columns=USERS:.userNames,GROUPS:.groupNames


for i in `oc get pv  -o=custom-columns=NAME:.metadata.name | grep pvc` ;
   do oc describe pv $i | grep Path |awk '{print $2}';
done
~~~

## Regenerate IGN files

~~~bash

$ oc extract -n openshift-machine-api secret/master-user-data --keys=userData --to=-
$ oc extract -n openshift-machine-api secret/worker-user-data --keys=userData --to=-

~~~

## Check Namespaces Bound to Container

~~~bash

$ lsns -p <pid>

~~~
