PCI=$PCIDEVICE_OPENSHIFT_IO_SRIOV_DPDK_ENS4F0
MAC=`cat /root/mapping.txt | grep $PCI | awk '{print $3}'`
( echo 'start' ; while true ; do echo 'show port stats all' ; sleep 60 ; done ) | dpdk-testpmd -n 4 -l `cat /sys/fs/cgroup/cpuset/cpuset.cpus` -a $PCIDEVICE_OPENSHIFT_IO_SRIOV_DPDK_ENS4F0 --socket-mem 1024 --vdev=virtio_user0,path=/dev/vhost-net,mac=$MAC -- -i
sleep infinity