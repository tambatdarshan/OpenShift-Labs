#!/usr/bin/env bash
LOGFILE=/tmp/dummy.log
> $LOGFILE

log () {
  >>$LOGFILE echo $1
}

# Outputs an essentially dummy CNI result that's borderline acceptable by the spec.
# https://github.com/containernetworking/cni/blob/master/SPEC.md#result
cniresult () {
    cat << EOF
{
  "cniVersion": "0.4.0",
  "interfaces": [
      {
          "name": "dummy"
      }
  ],
  "ips": []
}
EOF
}

# Overarching basic parameters.
containerifname=eth1

log "CNI method: $CNI_COMMAND"
log "CNI container id: $CNI_CONTAINERID"
log "CNI netns: $CNI_NETNS"

stdin=`cat /dev/stdin`
log "stdin: $stdin"

if [[ $CNI_COMMAND == "ADD" ]]; then
  cniresult
fi