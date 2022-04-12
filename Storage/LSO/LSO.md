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

## Further Look

~~~bash

# Kubelet Logs

Apr 11 13:18:18 ip-10-0-150-204 hyperkube[1819]: I0411 13:18:18.105182    1819 mount_linux.go:425] Disk "/mnt/local-storage/local-sc/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b" appears to be unformatted, attempting to format as type: "xfs" with options: [/mnt/local-storage/local-sc/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b]
Apr 11 13:18:18 ip-10-0-150-204 hyperkube[1819]: I0411 13:18:18.345534    1819 mount_linux.go:435] Disk successfully formatted (mkfs): xfs - /mnt/local-storage/local-sc/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b /var/lib/kubelet/plugins/kubernetes.io/local-volume/mounts/local-pv-6abafcd5
Apr 11 13:18:18 ip-10-0-150-204 hyperkube[1819]: I0411 13:18:18.398151    1819 operation_generator.go:616] MountVolume.MountDevice succeeded for volume "local-pv-6abafcd5" (UniqueName: "kubernetes.io/local-volume/local-pv-6abafcd5") pod "rhel7" (UID: "533d00bb-9bcd-4866-ade9-07f7cdea752f") device mount path "/var/lib/kubelet/plugins/kubernetes.io/local-volume/mounts/local-pv-6abafcd5"

# Login to Worker and verify

$ oc debug node/<worker node>

sh-4.4# file /mnt/local-storage/local-sc/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b
/mnt/local-storage/local-sc/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b: symbolic link to /dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b
sh-4.4# ls -l /dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b
lrwxrwxrwx. 1 root root 13 Apr 11 13:18 /dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol03b41e4841132a96b -> ../../nvme1n1
sh-4.4#

~~~
