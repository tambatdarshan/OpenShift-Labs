# Metal LB

## Installation

~~~bash

$ oc new-project metallb-system # Then Install the Metal LB Operator from OperatorHub
~~~

## Create MetalLB CR

~~~bash

$ oc apply -f files/metallb-cr.yaml

$ oc get all -n metallb-system
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/controller-b8f4c8565-kzd4l                             2/2     Running   0          32m
pod/metallb-operator-controller-manager-8676679d9d-tvvcs   1/1     Running   0          37m
pod/speaker-899k9                                          6/6     Running   0          32m

NAME                                                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)               AGE
service/metallb-controller-monitor-service            ClusterIP   None            <none>        29150/TCP             32m
service/metallb-operator-controller-manager-service   ClusterIP   172.30.246.20   <none>        443/TCP               37m
service/metallb-speaker-monitor-service               ClusterIP   None            <none>        29150/TCP,29151/TCP   32m
service/webhook-service                               ClusterIP   172.30.252.58   <none>        443/TCP               37m

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/speaker   1         1         1       1            1           kubernetes.io/os=linux   32m

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller                            1/1     1            1           32m
deployment.apps/metallb-operator-controller-manager   1/1     1            1           37m

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-b8f4c8565                             1         1         1       32m
replicaset.apps/metallb-operator-controller-manager-8676679d9d   1         1         1       37m
~~~

## Create AddressPools CR

~~~bash

$ oc apply -f files/addresspools-cr.yaml

~~~

## Test

### Environment: SNO OCP 4.10.30 IP: 10.72.36.88

~~~bash

$ oc get nodes -o wide
NAME                                    STATUS   ROLES           AGE    VERSION           INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                                        KERNEL-VERSION                 CONTAINER-RUNTIME
dell-per430-35.gsslab.pek2.redhat.com   Ready    master,worker   4d3h   v1.23.5+012e945   10.72.36.88   <none>        Red Hat Enterprise Linux CoreOS 410.84.202208161501-0 (Ootpa)   4.18.0-305.57.1.el8_4.x86_64   cri-o://1.23.3-15.rhaos4.10.git6af791c.el8

~~~

### Create Nginx Deployment and Service

~~~bash

$ oc apply -f files/metallb-deployment-web.yaml
$ oc apply -f files/metallb-svc-web.yaml

$ oc get all
NAME                       READY   STATUS    RESTARTS   AGE
pod/web-6d5796449f-8vskh   1/1     Running   0          7h11m

NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)          AGE
service/nginx-service   LoadBalancer   172.30.163.110   10.72.36.222   8080:31903/TCP   7h11m # Pay attention to EXTERNAL-IP = 10.72.36.222 while the addressPools = 10.72.36.222 - 10.72.36.225

NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web   1/1     1            1           7h11m

NAME                             DESIRED   CURRENT   READY   AGE
replicaset.apps/web-6d5796449f   1         1         1       7h11m

~~~

* From a Client

~~~bash

$ ifconfig utun3
utun3: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 1500
    inet 10.72.12.237 --> 10.72.12.237 netmask 0xfffffc00

$ w3m http://10.72.36.222:8080 # Pay attention to the port 8080 because the port of service is 8080
Welcome to nginx!

If you see this page, the nginx web server is successfully installed and working. Further configuration is required.

For online documentation and support please refer to nginx.org.
Commercial support is available at nginx.com.

Thank you for using nginx.
~~~

~~~bash

$ oc delete svc nginx-service # Release the IP because the lab could use it

~~~
