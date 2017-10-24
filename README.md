This folder shows an example of Terraform code to deploy a Nomad cluster that connects to a separate Consul cluster in AWS (if you want to run Nomad and Consul in the same clusters, see the nomad-consul-colocated-cluster example instead). The Nomad cluster consists of two Auto Scaling Groups (ASGs): one with a small number of Nomad server nodes, which are responsible for being part of the concensus quorum, and one with a larger number of Nomad client nodes, which are used to run jobs:

Nomad architecture

You will need to create an Amazon Machine Image (AMI) that has Nomad and Consul installed, which you can do using the nomad-consul-ami example).

For more info on how the Nomad cluster works, check out the nomad-cluster documentation.

Quick start

To deploy a Nomad Cluster:

git clone this repo to your computer.
Build a Nomad and Consul AMI. See the nomad-consul-ami example documentation for instructions. Make sure to note down the ID of the AMI.
Install Terraform.
Open vars.tf, set the environment variables specified at the top of the file, and fill in any other variables that don't have a default, including putting your AMI ID into the ami_id variable.
Run terraform get.
Run terraform plan.
If the plan looks good, run terraform apply.
Run the nomad-examples-helper.sh script to print out the IP addresses of the Nomad servers and some example commands you can run to interact with the cluster: ../nomad-examples-helper/nomad-examples-helper.sh

https://github.com/hashicorp/terraform-aws-nomad/tree/master/examples/nomad-consul-ami
