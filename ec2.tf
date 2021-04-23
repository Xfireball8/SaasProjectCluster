resource "aws_vpc" "cluster_vpc" {
  cidr_block = "192.168.2.0/27"

  tags = {
    project = "saas"
  }
}
