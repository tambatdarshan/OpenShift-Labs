for pv in `oc get pv | grep Released | awk '{print $1}'`; do
    disk=`oc get pv $pv -o jsonpath='{.spec.local.path}'`
    oc delete $pv
    mkfs -F $disk
    wipefs -a $disk
done