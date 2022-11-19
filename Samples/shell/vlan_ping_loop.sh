for i in $(seq 1 100); do
    echo "Attempt #$i"
    oc delete -f sriov-pod1.yaml
    sleep 5
    oc apply -f sriov-pod1.yaml
    sleep 10
    oc exec -it sriovpod1 -- ip link add link test2 name f1 type vlan id 545
    oc exec -it sriovpod1 -- ip link set f1 up
    oc exec -it sriovpod1 -- ip link set test2 mtu 1500
    oc exec -it sriovpod1 -- ip link set f1 mtu 1500
    oc exec -it sriovpod1 -- ip addr add 10.110.203.27/26 dev f1

    oc exec -it sriovpod2 -- ip link add link test2 name f1 type vlan id 545
    oc exec -it sriovpod2 -- ip link set f1 up
    oc exec -it sriovpod2 -- ip link set test2 mtu 1500
    oc exec -it sriovpod2 -- ip link set f1 mtu 1500
    oc exec -it sriovpod2 -- ip addr add 10.110.203.24/26 dev f1

    sleep 2

    oc exec -it sriovpod1 -- ping -W1 -c 5 10.110.203.24
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "Ping failed and issue reproduced"
        break
    fi
done