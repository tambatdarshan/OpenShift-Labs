# OVN-Kubernetes

## Architecture

* Basic call order of OVN

North Bound -> ovn-northd -> South Bound -> ovn-controller -> ovs DB -> vswitchd

* Check Pods:

~~~bash
$ oc get pods -n openshift-ovn-kubernetes
ovnkube-master-fcfpg   6/6     Running   3          4d4h
ovnkube-master-hz7cn   6/6     Running   6          4d4h
ovnkube-master-jrs2w   6/6     Running   6          4d4h
ovnkube-node-4lj9t     4/4     Running   0          4d4h
ovnkube-node-5dhgt     4/4     Running   0          4d4h
ovnkube-node-c76xv     4/4     Running   0          4d4h
ovnkube-node-h4sgh     4/4     Running   1          4d4h
ovnkube-node-m7gjl     4/4     Running   0          4d4h
ovnkube-node-v6v7p     4/4     Running   0          4d4h
~~~

## Useful Commands to Troubleshoot

* Check logical flows in SB

~~~bash
$ oc rsh ovnkube-master-fcfpg

$ sh-4.4# ovn-sbctl lflow-list | grep Datapath
Datapath: "GR_dell-per430-35.gsslab.pek2.redhat.com" (bffd54ec-6280-44e1-8ab8-cda6e85024fc)  Pipeline: ingress
Datapath: "GR_dell-per430-35.gsslab.pek2.redhat.com" (bffd54ec-6280-44e1-8ab8-cda6e85024fc)  Pipeline: egress
Datapath: "dell-per430-35.gsslab.pek2.redhat.com" (fc138e3e-0fa0-485a-9178-86e990f510d9)  Pipeline: ingress
Datapath: "dell-per430-35.gsslab.pek2.redhat.com" (fc138e3e-0fa0-485a-9178-86e990f510d9)  Pipeline: egress
Datapath: "ext_dell-per430-35.gsslab.pek2.redhat.com" (35a9e839-7ef0-42d5-ab97-523b3ae94dc4)  Pipeline: ingress
Datapath: "ext_dell-per430-35.gsslab.pek2.redhat.com" (35a9e839-7ef0-42d5-ab97-523b3ae94dc4)  Pipeline: egress
Datapath: "join" (1f7c7d60-aacd-4caa-bfde-80220b64f54f)  Pipeline: ingress
Datapath: "join" (1f7c7d60-aacd-4caa-bfde-80220b64f54f)  Pipeline: egress
Datapath: "ovn_cluster_router" (9e564c66-ada4-4c64-a5ed-324dfa2840c4)  Pipeline: ingress
Datapath: "ovn_cluster_router" (9e564c66-ada4-4c64-a5ed-324dfa2840c4)  Pipeline: egress

## If you rsh to ovn-node Pods, you need to specify DB URL and Certs like:

$ oc describe ep ovnkube-db -n openshift-ovn-kubernetes
Name:         ovnkube-db
Namespace:    openshift-ovn-kubernetes
Labels:       service.kubernetes.io/headless=
Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2022-08-08T09:43:03Z
Subsets:
  Addresses:          10.0.128.218,10.0.175.92,10.0.199.196
  NotReadyAddresses:  <none>
  Ports:
    Name   Port  Protocol
    ----   ----  --------
    south  9642  TCP
    north  9641  TCP


sh-4.4# ovn-nbctl --db ssl:10.0.128.218:9641 -p /ovn-cert/tls.key -c /ovn-cert/tls.crt -C /ovn-ca/ca-bundle.crt show

sh-4.4# ovn-sbctl --db ssl:10.0.128.218:9642 -p /ovn-cert/tls.key -c /ovn-cert/tls.crt -C /ovn-ca/ca-bundle.crt lflow-list
~~~

* Simulate Sending Packet by Using ovn-trace in an SNO

~~~bash

$ oc get pods -n test-sctp -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP            NODE                                    NOMINATED NODE   READINESS GATES
sctpclient   1/1     Running   0          31h   10.128.0.81   dell-per430-35.gsslab.pek2.redhat.com   <none>           <none>
sctpserver   1/1     Running   0          31h   10.128.0.79   dell-per430-35.gsslab.pek2.redhat.com   <none>           <none>

$ oc get pods -n openshift-ovn-kubernetes
NAME                   READY   STATUS    RESTARTS   AGE
ovnkube-master-8xc4v   6/6     Running   24         9d
ovnkube-node-gx866     5/5     Running   20         9d

$ oc rsh ovnkube-master-8xc4v

sh-4.4# ovn-sbctl lflow-list dell-per430-35.gsslab.pek2.redhat.com | grep sctpclient
  table=0 (ls_in_port_sec_l2  ), priority=50   , match=(inport == "test-sctp_sctpclient" && eth.src == {0a:58:0a:80:00:51}), action=(next;)
  table=1 (ls_in_port_sec_ip  ), priority=90   , match=(inport == "test-sctp_sctpclient" && eth.src == 0a:58:0a:80:00:51 && ip4.src == 0.0.0.0 && ip4.dst == 255.255.255.255 && udp.src == 68 && udp.dst == 67), action=(next;)
  table=1 (ls_in_port_sec_ip  ), priority=90   , match=(inport == "test-sctp_sctpclient" && eth.src == 0a:58:0a:80:00:51 && ip4.src == {10.128.0.81}), action=(next;)
  table=1 (ls_in_port_sec_ip  ), priority=80   , match=(inport == "test-sctp_sctpclient" && eth.src == 0a:58:0a:80:00:51 && ip), action=(drop;)
  table=2 (ls_in_port_sec_nd  ), priority=90   , match=(inport == "test-sctp_sctpclient" && eth.src == 0a:58:0a:80:00:51 && arp.sha == 0a:58:0a:80:00:51 && arp.spa == {10.128.0.81}), action=(next;)
  table=2 (ls_in_port_sec_nd  ), priority=80   , match=(inport == "test-sctp_sctpclient" && (arp || nd)), action=(drop;)
  table=18(ls_in_arp_rsp      ), priority=100  , match=(arp.tpa == 10.128.0.81 && arp.op == 1 && inport == "test-sctp_sctpclient"), action=(next;)
  table=24(ls_in_l2_lkup      ), priority=50   , match=(eth.dst == 0a:58:0a:80:00:51), action=(outport = "test-sctp_sctpclient"; output;)
  table=8 (ls_out_port_sec_ip ), priority=90   , match=(outport == "test-sctp_sctpclient" && eth.dst == 0a:58:0a:80:00:51 && ip4.dst == {255.255.255.255, 224.0.0.0/4, 10.128.0.81}), action=(next;)
  table=8 (ls_out_port_sec_ip ), priority=80   , match=(outport == "test-sctp_sctpclient" && eth.dst == 0a:58:0a:80:00:51 && ip), action=(drop;)
  table=9 (ls_out_port_sec_l2 ), priority=50   , match=(outport == "test-sctp_sctpclient" && eth.dst == {0a:58:0a:80:00:51}), action=(output;)

# This ovn-trace simulates sending packet from sctpserver port to 10.128.0.81

sh-4.4# ovn-trace dell-per430-35.gsslab.pek2.redhat.com --ct new 'inport == "test-sctp_sctpserver" && eth.src == 0a:58:0a:80:00:4f && ip4.src == {10.128.0.79} && eth.dst == 0a:58:0a:80:00:51 && ip4.dst == {10.128.0.81} && sctp.dst == 30102 && sctp.src == 30102 && sctp'
# sctp,reg14=0x66f,vlan_tci=0x0000,dl_src=0a:58:0a:80:00:4f,dl_dst=0a:58:0a:80:00:51,nw_src=10.128.0.79,nw_dst=10.128.0.81,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=30102,tp_dst=30102

ingress(dp="dell-per430-35.gsslab.pek2.redhat.com", inport="test-sctp_sctpserver")
----------------------------------------------------------------------------------
 0. ls_in_port_sec_l2 (northd.c:5511): inport == "test-sctp_sctpserver" && eth.src == {0a:58:0a:80:00:4f}, priority 50, uuid aff87fc3
    next;
 1. ls_in_port_sec_ip (northd.c:5144): inport == "test-sctp_sctpserver" && eth.src == 0a:58:0a:80:00:4f && ip4.src == {10.128.0.79}, priority 90, uuid 7473bc64
    next;
 5. ls_in_pre_acl (northd.c:5747): ip, priority 100, uuid 3e66f9c6
    reg0[0] = 1;
    next;
 6. ls_in_pre_lb (northd.c:5875): ip, priority 100, uuid 484985d6
    reg0[2] = 1;
    next;
 7. ls_in_pre_stateful (northd.c:5902): reg0[2] == 1 && ip4 && sctp, priority 120, uuid ac2e19b9
    reg1 = ip4.dst;
    reg2[0..15] = sctp.dst;
    ct_lb;

ct_lb
-----
 8. ls_in_acl_hint (northd.c:5975): ct.new && !ct.est, priority 7, uuid 2356523d
    reg0[7] = 1;
    reg0[9] = 1;
    next;
 9. ls_in_acl (northd.c:6422): ip && (!ct.est || (ct.est && ct_label.blocked == 1)), priority 1, uuid 4c4ad65b
    reg0[1] = 1;
    next;
14. ls_in_stateful (northd.c:6807): reg0[1] == 1 && reg0[13] == 0, priority 100, uuid 109992c7
    ct_commit { ct_label.blocked = 0; };
    next;
15. ls_in_pre_hairpin (northd.c:6834): ip && ct.trk, priority 100, uuid 25e90e64
    reg0[6] = chk_lb_hairpin();
    reg0[12] = chk_lb_hairpin_reply();
    *** chk_lb_hairpin_reply action not implemented
    next;
24. ls_in_l2_lkup (northd.c:8252): eth.dst == 0a:58:0a:80:00:51, priority 50, uuid 7beafc33
    outport = "test-sctp_sctpclient";
    output;

egress(dp="dell-per430-35.gsslab.pek2.redhat.com", inport="test-sctp_sctpserver", outport="test-sctp_sctpclient")
-----------------------------------------------------------------------------------------------------------------
 0. ls_out_pre_lb (northd.c:5877): ip, priority 100, uuid ebb28a2a
    reg0[2] = 1;
    next;
 1. ls_out_pre_acl (northd.c:5749): ip, priority 100, uuid c2fb3f8a
    reg0[0] = 1;
    next;
 2. ls_out_pre_stateful (northd.c:5922): reg0[2] == 1, priority 110, uuid bfbf2db6
    ct_lb;

ct_lb /* default (use --ct to customize) */
-------------------------------------------
 3. ls_out_acl_hint (northd.c:6027): ct.est && ct_label.blocked == 0, priority 1, uuid baea188d
    reg0[10] = 1;
    next;
 8. ls_out_port_sec_ip (northd.c:5144): outport == "test-sctp_sctpclient" && eth.dst == 0a:58:0a:80:00:51 && ip4.dst == {255.255.255.255, 224.0.0.0/4, 10.128.0.81}, priority 90, uuid 7051fd2b
    next;
 9. ls_out_port_sec_l2 (northd.c:5609): outport == "test-sctp_sctpclient" && eth.dst == {0a:58:0a:80:00:51}, priority 50, uuid ce99ea0f
    output;
    /* output to "test-sctp_sctpclient", type "" */
~~~
