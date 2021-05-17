#!/bin/bash

CONFIGURE_DIR=$PWD

#Creating tree

mkdir pki kubeconfigs encryption
mkdir pki/ca pki/master pki/worker-A pki/worker-B
mkdir kubeconfigs/master kubeconfigs/worker-A kubeconfigs/worker-B

#CA creation

cd $CONFIGURE_DIR/pki/ca
cfssl gencert -initca $CONFIGURE_DIR/certs_configuration/ca-csr.json | cfssljson -bare ca


#Master Certs Creation

cd $CONFIGURE_DIR/pki/master/

  # Admin k8s Account
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
  $CONFIGURE_DIR/certs_configuration/admin-csr.json | cfssljson -bare admin

  # Controller Manager
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
$CONFIGURE_DIR/certs_configuration/kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

  # Scheduler
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
$CONFIGURE_DIR/certs_configuration/kube-scheduler-csr.json | cfssljson -bare kube-scheduler

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
  # API Server
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
  -hostname=10.240.0.1,192.168.1.62,127.0.0.1,${KUBERNETES_HOSTNAMES} \
$CONFIGURE_DIR/certs_configuration/kubernetes-csr.json | cfssljson -bare kube-apiserver

  # k8s Service Account
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
$CONFIGURE_DIR/certs_configuration/service-account-csr.json | cfssljson -bare service-account

#Worker Certs Creation

cd $CONFIGURE_DIR/pki/

  # kube-proxy
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
$CONFIGURE_DIR/certs_configuration/kube-proxy-csr.json | cfssljson -bare kube-proxy

  # worker-A kubelet
cd $CONFIGURE_DIR/pki/worker-A/
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
  -hostname=ip-192-168-1-60.eu-west-3.compute.internal,192.168.1.60 \
$CONFIGURE_DIR/certs_configuration/worker-A-csr.json | cfssljson -bare kubelet-A

  # worker-B kubelet
cd $CONFIGURE_DIR/pki/worker-B/
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
  -ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
  -config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
  -profile=kubernetes \
  -hostname=ip-192-168-1-59.eu-west-3.compute.internal,192.168.1.59 \
$CONFIGURE_DIR/certs_configuration/worker-B-csr.json | cfssljson -bare kubelet-B

#Master Components Kubeconfigs

cd $CONFIGURE_DIR/kubeconfigs/master

# ETCD Service

cat > etcd.service << EOF
[Unit]
Description=etcd

[Service]
Type=notify
ExecStart=/bin/etcd \
  --name ip-192-168-1-62.eu-west-3.compute.internal \
  --cert-file=/etc/etcd/cert.pem \
  --key-file=/etc/etcd/cert-key.pem \
  --peer-cert-file=/etc/etcd/cert.pem \
  --peer-key-file=/etc/etcd/cert-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://192.168.1.62:2380 \
  --listen-peer-urls https://102.168.1.62:2380 \
  --listen-client-urls https://192.168.1.62:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://192.168.1.62:2379 \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# TODO : API Server Service

cat > kube-apiserver.service << EOF
[Unit]
Description=Kubernetes Component : API Server

[Service]
ExecStart=/bin/kube-apiserver \
  # General Settings 
  --advertise-address=192.168.1.62 \
  --apiserver-count=1 \
  --bind-address=127.0.0.1 \
  --secure-port=6443 \
  --cloud-provider=aws \
  # Network Settings
  --service-cluster-ip-range=10.32.0.0/16 \
  --service-node-port-range=30000-32767 \
  # Authorization
  --authorization-mode=Node,RBAC \
  # Authentication
  --client-ca-file=/var/lib/kube-apiserver/ca.pem \
  --tls-cert-file=/var/lib/kube-apiserver/cert.pem \
  --tls-private-key-file=/var/lib/kube-apiserver/cert-key.pem \
  # Etcd Settings
  --etcd-servers=https://192.168.1.62:2379
Restart=on-failure

[Install]
WantedBy=kubernetes-ready.target
EOF

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=$CONFIGURE_DIR/pki/master/kube-controller-manager.pem \
  --client-key=$CONFIGURE_DIR/pki/master/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig

# TODO : Controller Manager Service

cat > kube-controller-manager.service << EOF
[Unit]
Description=Kubernetes Component : Controller Manager

[Service]
ExecStart=/bin/kube-controller-manager \
  # General Settings
  --bind-address=0.0.0.0 \
  --master=127.0.0.1:6443 \
  --cloud-provider=aws \
  --cluster-name=kubernetes \
  # Network Settings
  --allocate-node-cidr=true \
  --configure-cloud-routes=true \
  --cluster-cidr=10.200.0.0/16 \
  --service-cluster-ip-range=10.32.0.0/16 \
  --node-cidr-mask-size=16 \
  --flex-volume-plugin-dir=/etc/kubernetes/kubelet-plugins/volume/exec/ \
  # Authentication Settings
  --client-ca-file=/var/lib/kube-controller-manager/ca.pem \
  --tls-cert-file=/var/lib/kube-controller-manager/cert.pem \
  --tls-private-key-file=/var/lib/kube-controller-manager/cert-key.pem \
  # Authorization Settings
  --kubeconfig=/var/lib/kube-controller-manager/kubeconfig
Restart=on-failure

[Install]
WantedBy=kubernetes-ready.target
EOF

  # Scheduler

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=$CONFIGURE_DIR/pki/master/kube-scheduler.pem \
  --client-key=$CONFIGURE_DIR/pki/master/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

# TODO : Scheduler Service

cat > kube-scheduler.service << EOF
[Unit]
Description=Kubernetes Component : Scheduler

[Service]
ExecStart=/bin/kube-scheduler \
  # General Settings 
  --bind-address=0.0.0.0 \
  --master=127.0.0.1:6443 \
  # Authorization
  --config=/var/lib/kube-scheduler/kubeconfig \
  # Authentication
  --client-ca-file=/var/lib/kube-scheduler/ca.pem \
  --tls-cert-file=/var/lib/kube-scheduler/cert.pem \
  --tls-private-key-file=/var/lib/kube-scheduler/cert-key.pem \
Restart=on-failure

[Install]
WantedBy=kubernetes-ready.target
EOF

  # Admin client

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=$CONFIGURE_DIR/pki/master/admin.pem \
  --client-key=$CONFIGURE_DIR/pki/master/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/admin.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig

#Worker Components Kubeconfigs

cd $CONFIGURE_DIR/kubeconfigs/

# Kube-proxy Related Stuff 

# TODO : Kube-proxy Services

cat > kube-proxy.service << EOF
[Unit]
Description=Kubelet Component : Kube Proxy

[Service]
ExecStart=/bin/kube-proxy \
  # General Settings
  --bind-address=0.0.0.0 \
  --master=192.168.1.62 \
  --config=/var/lib/kube-proxy/config
  # Network Settings
  --cluster-cidr=10.200.0.0/16 \
  # Authorization
  --kubeconfig=/var/lib/kube-proxy/kubeconfig \  
Restart=on-failure

[Install]
WantedBy=kubernetes-ready.target
EOF

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://192.168.1.62:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=$CONFIGURE_DIR/pki/kube-proxy.pem \
  --client-key=$CONFIGURE_DIR/pki/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig \

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

# Kube-proxy config yaml file
cat > kube-proxy.config <<EOF
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

# Worker A assets generation

# TODO : Kubelet Services


cd $CONFIGURE_DIR/kubeconfigs/worker-A/

cat > kubelet-A.service << EOF
[Unit]
Description=Kubelet Worker A

[Service]
ExecStart=/bin/kubelet \
  # General Settings
  --node-ip=192.168.1.60 \
  --config=/var/lib/kubelet/config \
  --volume-plugin-dir=/var/lib/kubelet/volume/exec/ \
  # Container Runtime Parameter
  --container-runtime=docker \
  --docker-endpoint=unix://var/run/docker.sock \
  # Networking
  --cni-bin-dir=/usr/libexec/cni/ \
  --cni-conf-dir=/etc/cni/net.d/ \
  # Authorization
  --register-node=true \
  --kubeconfig=/var/lib/kubelet/kubeconfig
Restart=on-failure

[Install]
WantedBy=kubernetes-ready.target
EOF

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://192.168.1.62:6443 \
  --kubeconfig=kubelet-A.kubeconfig

kubectl config set-credentials system:node:ip-192-168-1-60.eu-west-3.compute.internal \
  --client-certificate=$CONFIGURE_DIR/pki/worker-A/worker-A.pem \
  --client-key=$CONFIGURE_DIR/pki/worker-A/worker-A-key.pem \
  --embed-certs=true \
  --kubeconfig=kubelet-A.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:node:ip-192-168-1-60.eu-west-3.compute.internal  \
  --kubeconfig=kubelet-A.kubeconfig

kubectl config use-context default --kubeconfig=kubelet-A.kubeconfig

# Kubelet Configuration

cat > kubelet-A.config <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubelet/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.0.0/16"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/cert.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/cert-key.pem"
cgroupDriver: "systemd"
EOF

# Worker B assets generation

cd $CONFIGURE_DIR/kubeconfigs/worker-B/

cat > kubelet-B.service << EOF
[Unit]
Description=Kubelet Worker B

[Service]
ExecStart=/bin/kubelet \
  # General Settings
  --node-ip=192.168.1.59 \
  --config=/var/lib/kubelet/config \
  --volume-plugin-dir=/var/lib/kubelet/volume/exec/ \
  # Container Runtime Parameter
  --container-runtime=docker \
  --docker-endpoint=unix://var/run/docker.sock \
  # Networking
  --cni-bin-dir=/usr/libexec/cni/ \
  --cni-conf-dir=/etc/cni/net.d/ \
  # Authorization
  --register-node=true \
  --kubeconfig=/var/lib/kubelet/kubeconfig
Restart=on-failure

[Install]
WantedBy=kubernetes-ready.target
EOF

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://192.168.1.62:6443 \
  --kubeconfig=kubelet-B.kubeconfig

kubectl config set-credentials system:node:ip-192-168-1-59.eu-west-3.compute.internal \
  --client-certificate=$CONFIGURE_DIR/pki/worker-B/worker-B.pem \
  --client-key=$CONFIGURE_DIR/pki/worker-B/worker-B-key.pem \
  --embed-certs=true \
  --kubeconfig=kubelet-B.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:node:ip-192-168-1-59.eu-west-3.compute.internal \
  --kubeconfig=kubelet-B.kubeconfig

kubectl config use-context default --kubeconfig=kubelet-B.kubeconfig

# Kubelet Configuration

cat > kubelet-B.config <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubelet/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.0.0/16"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/cert.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/cert-key.pem"
cgroupDriver: "systemd"
EOF

# Generate encryption-config

cd $CONFIGURE_DIR/encryption/

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

# End
cd $CONFIGURE_PATH
