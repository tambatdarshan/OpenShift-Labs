# Kubelet Certificate

<https://www.youtube.com/watch?v=gXz4cq3PKdg>

<https://kubernetes.io/docs/reference/access-authn-authz/kubelet-authn-authz/>

## kube-apiserver <----> kubelet

### Case 1. Client: kube-apiserver; Server: kubelet

#### Item 1. kubelet certificate and Key as the server, in short, kubelet-server-cert-key

* Path: `/var/lib/kubelet/pki/kubelet-server-current.pem`
* Verication

1. Dump the server certificate

    ~~~bash
    $ echo Q | openssl s_client -connect 192.168.0.109:10250 | openssl x509 -text -noout

    <Snip>
            Issuer: CN = kube-csr-signer_@1670558493
            Validity
                Not Before: Dec  9 06:00:46 2022 GMT
                Not After : Jan  8 04:01:34 2023 GMT
            Subject: O = system:nodes, CN = system:node:multi-osp-24dll-worker-0-lxqxw # Pay attention to the CN as the user, O as the group to authenticate. Yes the certificate extracts the user and group for further authenticate. Check clientCAFile later
                X509v3 Subject Alternative Name:
                    DNS:multi-osp-24dll-worker-0-lxqxw, IP Address:192.168.0.109
    <Snip>

    ~~~

2. Compare the above dumped server with `/var/lib/kubelet/pki/kubelet-server-current.pem` and they are 100% same

#### Item 2. kubelet trusted CA as the server

* Path: `/etc/kubernetes/kubelet-ca.crt`

~~~bash
$ cat /etc/kubernetes/kubelet.conf
<Snip>
authentication:
  x509:
    clientCAFile: /etc/kubernetes/kubelet-ca.crt
~~~

* clientCAFile: clientCAFile is the path to a PEM-encoded certificate bundle. If set, any request presenting a client certificate signed by one of the authorities in the bundle is authenticated with a username corresponding to the CommonName, and groups corresponding to the Organization in the client certificate.

<https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletX509Authentication>

* The connections from the API server to the kubelet are used for fetching logs for pods, attaching (through kubectl) to running pods, and using the kubelet’s port-forwarding functionality. These connections terminate at the kubelet’s HTTPS endpoint. By default, the API server does not verify the kubelet’s serving certificate, which makes the connection subject to man-in-the-middle attacks, and unsafe to run over untrusted and/or public networks. Enabling Kubelet certificate authentication ensures that the API server could authenticate the Kubelet before submitting any requests.

<https://docs.datadoghq.com/security/default_rules/cis-kubernetes-1.5.1-4.2.3/>

* Verification:

~~~bash
$ openssl x509 -in /etc/kubernetes/kubelet-ca.crt -text -noout
<Snip>
        Issuer: OU = openshift, CN = admin-kubeconfig-signer
        Validity
            Not Before: Dec  8 08:41:04 2022 GMT
            Not After : Dec  5 08:41:04 2032 GMT # 10 years validation for this CA cert
        Subject: OU = openshift, CN = admin-kubeconfig-signer
            X509v3 Basic Constraints: critical
                CA:TRUE

~~~

Item 3. kube-apiserver cert and key as the client
