resource "aws_vpc" "k8s_vpc" {
  cidr_block = "192.168.1.32/27"

  tags = {
    project = "saas"
  }
}

resource "aws_subnet" "cluster_network" {
  vpc_id = aws_vpc.k8s_vpc.id
  cidr_block = "192.168.1.32/27"

  tags = {
    project = "saas"
  }
}

resource "aws_internet_gateway" "cluster_internet_gateway" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    project = "saas"
  }
}

resource "aws_default_security_group" "security_group" {
  vpc_id = aws_vpc.k8s_vpc.id

  	ingress {
		protocol = "tcp"
		from_port = 22
		to_port = 22
		self = "true"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
		protocol = "-1"
		from_port = 0
		to_port = 0
		self = "true"
		cidr_blocks = ["192.168.1.32/27","10.200.0.0/16"]
	}

	egress {

		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

}

resource "aws_default_route_table" "routing_table" {
  default_route_table_id = aws_vpc.k8s_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster_internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_route_association" {
  subnet_id = aws_subnet.cluster_network.id
  route_table_id = aws_vpc.k8s_vpc.default_route_table_id
}

#resource "aws_instance" "control_plane" {
#	ami = var.kubernetesos_master_ami
#	instance_type = "t2.small"
#	associate_public_ip_address = "true"
#	subnet_id = aws_subnet.cluster_network.id
#	private_ip = "192.168.1.62"
#	user_data = file("ignition/master.ign")
#  iam_instance_profile = aws_iam_instance_profile.instances_profile.name 
#
#	root_block_device {
#		delete_on_termination = "true"
#		volume_size = 30
#		volume_type = "gp2"
#	}
#
#}
#
#resource "aws_instance" "worker_node_A" {
#	ami = var.kubernetesos_worker_ami
#	instance_type = "t2.small"
#	associate_public_ip_address = "true"
#	subnet_id = aws_subnet.cluster_network.id
#	private_ip = "192.168.1.60"
#	user_data = file("ignition/worker-A.ign")
#  iam_instance_profile = aws_iam_instance_profile.instances_profile.name 
#
#	root_block_device {
#		delete_on_termination = "true"
#		volume_size = 30
#		volume_type = "gp2"
#	}
#
#}
#
#resource "aws_instance" "worker_node_B" {
#	ami = var.kubernetesos_worker_ami
#	instance_type = "t2.small"
#	associate_public_ip_address = "true"
#	subnet_id = aws_subnet.cluster_network.id
#	private_ip = "192.168.1.59"
#	user_data = file("ignition/worker-B.ign")
#  iam_instance_profile = aws_iam_instance_profile.instances_profile.name 
#
#	root_block_device {
#		delete_on_termination = "true"
#		volume_size = 30
#		volume_type = "gp2"
#	}
#}

