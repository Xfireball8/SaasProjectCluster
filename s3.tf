resource "null_resource"  "assets_creation" {
  provisioner "local-exec" {
    command = "./configure.sh"
  }
}


resource "aws_s3_bucket_object" "master_ca_pem" {
  bucket = "saasproj"
  key = "instances/ca.pem"
  source = "pki/ca/ca.pem"

  tags ={
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "master_ca_key_pem" {
  bucket = "saasproj"
  key = "instances/ca-key.pem"
  source = "pki/ca/ca-key.pem"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

###### MASTER CERTS #####

resource "aws_s3_bucket_object" "admin_kubeconfig" {
  bucket = "saasproj"
  key = "instances/admin.kubeconfig"
  source = "kubeconfigs/master/admin.kubeconfig"

  tags ={
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "master_kubernetes_pem" {
  bucket = "saasproj"
  key = "instances/kubernetes.pem"
  source = "pki/master/kubernetes.pem"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "master_kubernetes_key_pem" {
  bucket = "saasproj"
  key = "instances/kubernetes-key.pem"
  source = "pki/master/kubernetes-key.pem"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "master_service-account_pem" {
  bucket = "saasproj"
  key = "instances/service-account.pem"
  source = "pki/master/service-account.pem"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "master_service-account_key_pem" {
  bucket = "saasproj"
  key = "instances/service-account-key.pem"
  source = "pki/master/service-account-key.pem"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

####### MASTER KUBECONFIGS #####


resource "aws_s3_bucket_object" "master_encryption-config_yaml" {
  bucket = "saasproj"
  key = "instances/encryption-config.yaml"
  source = "encryption/encryption-config.yaml"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "master_controller-manager_kubeconfig" {
  bucket = "saasproj"
  key = "instances/kube-controller-manager.kubeconfig"
  source = "kubeconfigs/master/kube-controller-manager.kubeconfig"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}


resource "aws_s3_bucket_object" "master_kube-scheduler_kubeconfig" {
  bucket = "saasproj"
  key = "instances/kube-scheduler.kubeconfig"
  source = "kubeconfigs/master/kube-scheduler.kubeconfig"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

####### WORKER CERTS ####

resource "aws_s3_bucket_object" "worker_A_pem" {
  bucket = "saasproj"
  key = "instances/worker-A.pem"
  source = "pki/worker-A/worker-A.pem"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_A_key_pem" {
  bucket = "saasproj"
  key = "instances/worker-A-key.pem"
  source = "pki/worker-A/worker-A-key.pem"


  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_A_kubeconfig" {
  bucket = "saasproj"
  key = "instances/worker-A.kubeconfig"
  source = "kubeconfigs/worker-A/worker-A.kubeconfig"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_A_kubelet_config"{
  bucket = "saasproj"
  key = "instances/kubelet-config-A.yaml"
  source = "kubeconfigs/worker-A/kubelet-config-A.yaml"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_B_pem" {
  bucket = "saasproj"
  key = "instances/worker-B.pem"
  source = "pki/worker-B/worker-B.pem"


  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_B_key_pem" {
  bucket = "saasproj"
  key = "instances/worker-B-key.pem"
  source = "pki/worker-B/worker-B-key.pem"

  tags ={
    project = "saas"
  }
}

resource "aws_s3_bucket_object" "worker_B_kubeconfig" {
  bucket = "saasproj"
  key = "instances/worker-B.kubeconfig"
  source = "kubeconfigs/worker-B/worker-B.kubeconfig"


  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_B_kubelet_config"{
  bucket = "saasproj"
  key = "instances/kubelet-config-B.yaml"
  source = "kubeconfigs/worker-B/kubelet-config-B.yaml"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_kube-proxy_kubeconfig" {
  bucket = "saasproj"
  key = "instances/kube-proxy.kubeconfig"
  source = "kubeconfigs/kube-proxy.kubeconfig"

  tags ={
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "worker_kube-proxy_config" {
  bucket = "saasproj"
  key = "instances/kube-proxy-config.yaml"
  source = "kubeconfigs/kube-proxy-config.yaml"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}
