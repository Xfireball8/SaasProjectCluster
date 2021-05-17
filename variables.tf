variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "kubernetesos_master_ami" {
  type = string
}

variable "kubernetesos_worker_ami" {
  type = string
}

output "master_node_ip" {
  value = aws_instance.control_plane.public_ip
}

output "worker_node_A_ip" {
  value = aws_instance.worker_node_A.public_ip
}

output "worker_node_B_ip" {
  value = aws_instance.worker_node_B.public_ip
}
