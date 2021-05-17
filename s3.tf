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

##### ADMIN CONFIG #####

resource "aws_s3_bucket_object" "admin-kubeconfig" {
  bucket = "saasproj"
  key = "instances/admin.kubeconfig"
  source = "kubeconfigs/master/admin.kubeconfig"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

########################


###### MASTER CERTS #####

###### ETCD SERVICE #######

resource "aws_s3_bucket_object" "etcd-service" {
  bucket = "saasproj"
  key = "instances/etcd.service"
  source = "kubeconfigs/master/etcd.service"
  
  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

###########################

#### API SERVER SERVICE ######

resource "aws_s3_bucket_object" "kube-apiserver-service" {
  bucket = "saasproj"
  key = "instances/kube-apiserver.service"
  source = "kubeconfigs/master/kube-apiserver.service"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

##############################

# API SERVER AUTHENTICATION #

resource "aws_s3_bucket_object" "kube-apiserver-cert-pem" {
  bucket = "saasproj"
  key = "instances/kube-apiserver.pem"
  source = "pki/master/kube-apiserver.pem"

  tags ={
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kube-apiserver-cert-key-pem" {
  bucket = "saasproj"
  key = "instances/kube-apiserver-key.pem"
  source = "pki/master/kube-apiserver-key.pem"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}
########## END ####################

#### CONTROLLER MANAGER SERVICE ######

resource "aws_s3_bucket_object" "kube-controller-manager-service" {
  bucket = "saasproj"
  key = "instances/kube-controller-manager.service"
  source = "kubeconfigs/master/kube-controller-manager.service"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

##############################

# CONTROLLER MANAGER AUTHENTICATION #

resource "aws_s3_bucket_object" "kube-controller-manager-pem" {
  bucket = "saasproj"
  key = "instances/kube-controller-manager.pem" 
  source = "pki/master/kube-controller-manager.pem"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kube-controller-manager-key-pem" {
  bucket = "saasproj"
  key = "instances/kube-controller-manager-key.pem" 
  source = "pki/master/kube-controller-manager-key.pem"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}
########## END ####################

### CONTROLLER MANAGER AUTHORIZATON ##

resource "aws_s3_bucket_object" "kube-controller-manager-kubeconfig" {
  bucket = "saasproj"
  key = "instances/kube-controller-manager.kubeconfig"
  source = "kubeconfigs/master/kube-controller-manager.kubeconfig"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

######################################

#### KUBE SCHEDULER SERVICE ######

resource "aws_s3_bucket_object" "kube-scheduler-service" {
  bucket = "saasproj"
  key = "instances/kube-scheduler.service"
  source = "kubeconfigs/master/kube-scheduler.service"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

##############################

# KUBE SCHEDULER AUTHENTICATION #

resource "aws_s3_bucket_object" "kube-scheduler-pem" {
  bucket = "saasproj"
  key = "instances/kube-scheduler.pem"
  source = "pki/master/kube-scheduler.pem"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kube-scheduler-key-pem" {
  bucket = "saasproj"
  key = "instances/kube-scheduler-key.pem"
  source = "pki/master/kube-scheduler-key.pem"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}
########## END ####################

##### KUBE SCHEDULER AUTHORIZATION #####

resource "aws_s3_bucket_object" "kube-scheduler-kubeconfig" {
  bucket = "saasproj"
  key = "instances/kube-scheduler.kubeconfig"
  source = "kubeconfigs/master/kube-scheduler.kubeconfig"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

########################################

########### KUBE PROXY SERVICE #########

resource "aws_s3_bucket_object" "kube-proxy-service" {
  bucket = "saasproj"
  key = "instances/kube-proxy.service"
  source = "kubeconfigs/kube-proxy.service"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kube-proxy-config"{
  bucket = "saasproj"
  key = "instances/kube-proxy.config"
  source = "kubeconfigs/kube-proxy.config"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

########################################

######  KUBE PROXY AUTHORIZATION #######

resource "aws_s3_bucket_object" "kube-proxy-kubeconfig"{
  bucket = "saasproj"
  key = "instances/kube-proxy.kubeconfig"
  source = "kubeconfigs/kube-proxy.kubeconfig"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

########################################

###### KUBELET A SERVICE ###############

resource "aws_s3_bucket_object" "kubelet-A-service"{
  bucket = "saasproj"
  key = "instances/kubelet-A.service"
  source = "kubeconfigs/worker-A/kubelet-A.service"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kubelet-A-config" {
  bucket = "saasproj"
  key = "instances/kubelet-A.config"
  source = "kubeconfigs/worker-A/kubelet-A.config"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

########################################

###### KUBELET A AUTHENTICATION ########

resource "aws_s3_bucket_object" "kubelet-A-pem" {
  bucket = "saasproj"
  key = "instances/kubelet-A.pem"
  source = "pki/worker-A/kubelet-A.pem"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kubelet-A-key-pem" {
  bucket = "saasproj"
  key = "instances/kubelet-A-key.pem"
  source = "pki/worker-A/kubelet-A-key.pem"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

########################################

###### KUBELET A AUTHORIZATION #########

resource "aws_s3_bucket_object" "kubelet-A-kubeconfig" {
  bucket = "saasproj"
  key = "instances/kubelet-A.kubeconfig"
  source = "kubeconfigs/worker-A/kubelet-A.kubeconfig"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

########################################


###### KUBELET B SERVICE ###############

resource "aws_s3_bucket_object" "kubelet-B-service" {
  bucket = "saasproj"
  key = "instances/kubelet-B.service"
  source = "kubeconfigs/worker-B/kubelet-B.service"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kubelet-B-config" {
  bucket = "saasproj"
  key = "instances/kubelet-B.config"
  source = "kubeconfigs/worker-B/kubelet-B.config"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

########################################

###### KUBELET B AUTHENTICATION ########

resource "aws_s3_bucket_object" "kubelet-B-pem" {
  bucket = "saasproj"
  key = "instances/kubelet-B.pem"
  source = "pki/worker-B/kubelet-B.pem"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kubelet-B-key-pem" {
  bucket = "saasproj"
  key = "instances/kubelet-B-key.pem"
  source = "pki/worker-B/kubelet-B-key.pem"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

########################################

###### KUBELET B AUTHORIZATION #########

resource "aws_s3_bucket_object" "kubelet-B-kubeconfig" {
  bucket = "saasproj"
  key = "instances/kubelet-B.kubeconfig"
  source = "kubeconfigs/worker-B/kubelet-B.kubeconfig"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}
########################################
