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

######### SERVICE AUTHENTICATON ######

resource "aws_s3_bucket_object" "service-account-pem" {
  bucket = "saasproj"
  key = "instances/service-account.pem"
  source = "pki/master/service-account.pem"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "service-account-key-pem" {
  bucket = "saasproj"
  key = "instances/service-account-key.pem"
  source = "pki/master/service-account-key.pem"

  tags = {
    project = "saas"
  }

  depends_on = [
    null_resource.assets_creation
  ]
}

######################################


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

###### KUBELET DOCKER OPTIONS ##########

resource "aws_s3_bucket_object" "docker" {
  bucket = "saasproj"
  key = "instances/docker"
  source = "kubeconfigs/docker"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]

}

########################################



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


###### KUBELET A NETWORK ###############

resource "aws_s3_bucket_object" "kubelet-A-loopback-conf" {
  bucket = "saasproj"
  key = "instances/kubelet-A-loopback-conf"
  source = "kubeconfigs/worker-A/99-loopback.conf"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kubelet-A-bridge-conf" {
  bucket = "saasproj"
  key = "instances/kubelet-A-bridge-conf"
  source = "kubeconfigs/worker-A/10-bridge.conf"

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

###### KUBELET B NETWORK ###############

resource "aws_s3_bucket_object" "kubelet-B-loopback-conf" {
  bucket = "saasproj"
  key = "instances/kubelet-B-loopback-conf"
  source = "kubeconfigs/worker-B/99-loopback.conf"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}

resource "aws_s3_bucket_object" "kubelet-B-bridge-conf" {
  bucket = "saasproj"
  key = "instances/kubelet-B-bridge-conf"
  source = "kubeconfigs/worker-B/10-bridge.conf"

  tags = {
    project = "saas"
  }
  
  depends_on = [
    null_resource.assets_creation
  ]
}


########################################
