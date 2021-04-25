WORK IN PROGRESS!!!!!!!

It's a learning project that deploys a Kubernetes Cluster and Gitlab on AWS under 5 Minutes.

This repo is the SaaS entreprise fictional administrator's infrastructure repo.

Rights and materials (Buckets & Workstations) that the admin needs has been set-up by the
super-admin, you can go to this repo to find the IaC associated to it.

The Ostree Configurations engineered to bring the cluster to the desired state 
are available in this repo for the controller nodes, and this repo for the worker nodes.

This project use as dependencies :
  - cfssl for PKI gen.
  - kubectl for kubeconfigs gen.
  - Terraform

This work is not meant to be used for development or deployment purpose, it's a big 
project that i did to learn to use Amazon AWS (S3/EC2/VPC/IAM) 
/ Terraform 
/ Fedora Core OS (Ostree/ignition/systemD) 
/ Kubernetes.

Nonetheless, if you want to test it on your account you need to setup terraforms variables.

Therefore you will need a programmatic access to Amazon AWS,you should use the account of a user
with at least the privilege granted by the super-admin of this project. You also need an S3 bucket to 
put the state file in. 

If you use the IaC of the super-admin repo you can replicate this setup easily.

Check the code here :

You then just have to use Terraform to build the cluster. 
$ terraform init
$ terraform plan
$ terraform apply

