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
  -hostname=10.32.0.1,192.168.1.62,127.0.0.1,${KUBERNETES_HOSTNAMES} \
$CONFIGURE_DIR/certs_configuration/kubernetes-csr.json | cfssljson -bare kube-apiserver

  # Service Account
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

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-controller-manager.kubeconfig

kubectl config set-credentials default-controller-manager \
  --client-certificate=$CONFIGURE_DIR/pki/master/kube-controller-manager.pem \
  --client-key=$CONFIGURE_DIR/pki/master/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=default-controller-manager \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig

# Scheduler

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-scheduler.kubeconfig

kubectl config set-credentials default-scheduler \
  --client-certificate=$CONFIGURE_DIR/pki/master/kube-scheduler.pem \
  --client-key=$CONFIGURE_DIR/pki/master/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=default-scheduler \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

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

cat > docker << EOF
# /etc/sysconfig/docker

# Modify these options if you want to change the way the docker daemon runs
OPTIONS="--selinux-enabled \
  --log-driver=journald \
  --storage-driver=overlay2 \
  --live-restore \
  --default-ulimit nofile=1024:1024 \
  --init-path /usr/libexec/docker/docker-init \
  --userland-proxy-path /usr/libexec/docker/docker-proxy \
  --iptables=false \
  --ip-masq=false
"
EOF

# Kube-proxy Related Stuff 

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

cd $CONFIGURE_DIR/kubeconfigs/worker-A/

cat > 10-bridge.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "10.200.1.0/24"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat > 99-loopback.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://192.168.1.62:6443 \
  --kubeconfig=kubelet-A.kubeconfig

kubectl config set-credentials system:node:ip-192-168-1-60.eu-west-3.compute.internal \
  --client-certificate=$CONFIGURE_DIR/pki/worker-A/kubelet-A.pem \
  --client-key=$CONFIGURE_DIR/pki/worker-A/kubelet-A-key.pem \
  --embed-certs=true \
  --kubeconfig=kubelet-A.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:node:ip-192-168-1-60.eu-west-3.compute.internal \
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
    enabled: false
  x509:
    clientCAFile: "/var/lib/kubelet/ca.pem"
authorization:
  mode: AlwaysAllow
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.1.0/24"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/cert.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/cert-key.pem"
cgroupDriver: "systemd"
EOF

# Worker B assets generation

cd $CONFIGURE_DIR/kubeconfigs/worker-B/

kubectl config set-cluster kubernetes \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://192.168.1.62:6443 \
  --kubeconfig=kubelet-B.kubeconfig

kubectl config set-credentials system:node:ip-192-168-1-59.eu-west-3.compute.internal \
  --client-certificate=$CONFIGURE_DIR/pki/worker-B/kubelet-B.pem \
  --client-key=$CONFIGURE_DIR/pki/worker-B/kubelet-B-key.pem \
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
    enabled: false
  x509:
    clientCAFile: "/var/lib/kubelet/ca.pem"
authorization:
  mode: AlwaysAllow
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.200.2.0/24"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/cert.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/cert-key.pem"
cgroupDriver: "systemd"
EOF

cat > 10-bridge.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "10.200.2.0/24"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

cat > 99-loopback.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
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
