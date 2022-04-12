# Local Storage Operator

## Create LocalVolume CR

~~~bash
$ oc apply files/LocalVolume.yaml
~~~

## Create Pod

~~~bash
$ oc apply -f files/pod.yaml
$ oc get pods
NAME    READY   STATUS    RESTARTS   AGE
rhel7   1/1     Running   15         15h

$ oc rsh rhel7
sh-4.2# ls /data/ | wc -l
0

sh-4.2# cd /data
sh-4.2# touch a b c d e f g
~~~

## Verify the files created in PV exists even deleting the POD

~~~bash
$ oc delete pod rhel7
$ oc apply files/pod.yaml
$ oc rsh rhel7
sh-4.2# ls /data/
a  b  c  d  e  f  g
~~~
