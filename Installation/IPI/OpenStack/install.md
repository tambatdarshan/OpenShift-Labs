# Install OpenShift on OpenStack IPI

## Pre Install Configuration

1. Download rc file from webconsole Project -> API Access -> Download OpenStack RC File
2. Create Floating IPs for API and Ingress

~~~bash

$ openstack floating ip create --description "api.multi-osp.cchen.work" provider_net_shared_3
$ openstack floating ip create --description "apps.multi-osp.cchen.work" provider_net_shared_3
$ openstack floating ip list --long -c 'Floating IP Address' -c Description
+---------------------+-----------------------------------+
| Floating IP Address | Description                       |
+---------------------+-----------------------------------+
| 10.0.111.112        | api.multi-osp.cchen.work          |
| 10.0.109.186        | apps.multi-osp.cchen.work         |
+---------------------+-----------------------------------+

$ openstack floating ip set --tag reserve 10.0.111.112
$ openstack floating ip set --tag reserve 10.0.109.186

~~~
