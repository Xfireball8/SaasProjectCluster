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
-hostname=10.240.0.1,10.0.2.15,127.0.0.1,${KUBERNETES_HOSTNAMES} \
$CONFIGURE_DIR/certs_configuration/kubernetes-csr.json | cfssljson -bare kubernetes

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
-hostname=ip-192-168-1-60.eu-west-3.compute.internal,10.0.2.16 \
$CONFIGURE_DIR/certs_configuration/worker-A-csr.json | cfssljson -bare worker-A

  # worker-B kubelet
cd $CONFIGURE_DIR/pki/worker-B/
cfssl gencert -ca=$CONFIGURE_DIR/pki/ca/ca.pem \
-ca-key=$CONFIGURE_DIR/pki/ca/ca-key.pem \
-config=$CONFIGURE_DIR/certs_configuration/ca-config.json \
-profile=kubernetes \
-hostname=ip-192-168-1-59.eu-west-3.compute.internal,10.0.2.17 \
$CONFIGURE_DIR/certs_configuration/worker-B-csr.json | cfssljson -bare worker-B

#Master Components Kubeconfigs

cd $CONFIGURE_DIR/kubeconfigs/master

kubectl config set-cluster kubernetes-the-hard-way \
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
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-controller-manager \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig

  # Scheduler

kubectl config set-cluster kubernetes-the-hard-way \
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
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-scheduler \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig

  # Admin client

kubectl config set-cluster kubernetes-the-hard-way \
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
  --cluster=kubernetes-the-hard-way \
  --user=admin \
  --kubeconfig=$CONFIGURE_DIR/kubeconfigs/master/admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig

#Worker Components Kubeconfigs

cd $CONFIGURE_DIR/kubeconfigs/

# Kube-proxy Related Stuff 

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://10.0.2.15:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=$CONFIGURE_DIR/pki/kube-proxy.pem \
  --client-key=$CONFIGURE_DIR/pki/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig \

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

# Kube-proxy config yaml file
cat > kube-proxy-config.yaml <<EOF
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

# Worker A assets generation

cd $CONFIGURE_DIR/kubeconfigs/worker-A/

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://10.0.2.15:6443 \
  --kubeconfig=worker-A.kubeconfig

kubectl config set-credentials system:node:worker-A \
  --client-certificate=$CONFIGURE_DIR/pki/worker-A/worker-A.pem \
  --client-key=$CONFIGURE_DIR/pki/worker-A/worker-A-key.pem \
  --embed-certs=true \
  --kubeconfig=worker-A.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:node:worker-A  \
  --kubeconfig=worker-A.kubeconfig

kubectl config use-context default --kubeconfig=worker-A.kubeconfig

# Kubelet Configuration

cat > kubelet-config-A.yaml <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.0.2.0/24"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/worker-A.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/worker-A-key.pem"
EOF

# Worker B assets generation

cd $CONFIGURE_DIR/kubeconfigs/worker-B/

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=$CONFIGURE_DIR/pki/ca/ca.pem \
  --embed-certs=true \
  --server=https://10.0.2.15:6443 \
  --kubeconfig=worker-B.kubeconfig

kubectl config set-credentials system:node:worker-B \
  --client-certificate=$CONFIGURE_DIR/pki/worker-B/worker-B.pem \
  --client-key=$CONFIGURE_DIR/pki/worker-B/worker-B-key.pem \
  --embed-certs=true \
  --kubeconfig=worker-B.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:node:worker-B \
  --kubeconfig=worker-B.kubeconfig

kubectl config use-context default --kubeconfig=worker-B.kubeconfig

# Kubelet Configuration

cat > kubelet-config-B.yaml <<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "10.0.2.0/24"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/worker-B.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/worker-B-key.pem"
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
