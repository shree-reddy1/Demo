
provider "aws" {
  access_key = ""
  secret_key = ""
  region = "${var.aws_region}"
}

terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------

module "nomad_servers" {
  source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=v0.0.2"

  cluster_name  = "${var.nomad_cluster_name}-server"
  instance_type = "t2.micro"

  min_size         = "${var.num_nomad_servers}"
  max_size         = "${var.num_nomad_servers}"
  desired_capacity = "${var.num_nomad_servers}"

  ami_id    = "${var.ami_id}"
  user_data = "${data.template_file.user_data_nomad_server.rendered}"

  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.0.3"

  iam_role_id = "${module.nomad_servers.iam_role_id}"
}

data "template_file" "user_data_nomad_server" {
  template = "${file("${path.module}/user-data-nomad-server.sh")}"

  vars {
    num_servers       = "${var.num_nomad_servers}"
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------

module "consul_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.0.3"

  cluster_name  = "${var.consul_cluster_name}-server"
  cluster_size  = "${var.num_consul_servers}"
  instance_type = "t2.micro"

  cluster_tag_key   = "${var.cluster_tag_key}"
  cluster_tag_value = "${var.consul_cluster_name}"

  ami_id    = "${var.ami_id}"
  user_data = "${data.template_file.user_data_consul_server.rendered}"

  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER EC2 INSTANCE WHEN IT'S BOOTING
# This script will configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_consul_server" {
  template = "${file("${path.module}/user-data-consul-server.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# ---------------------------------------------------------------------------------------------------------------------

module "nomad_clients" {
  source = "github.com/hashicorp/terraform-aws-nomad.git//modules/nomad-cluster?ref=v0.0.2"
  cluster_name  = "${var.nomad_cluster_name}-client"
  instance_type = "t2.micro"

  min_size         = "${var.num_nomad_clients}"
  max_size         = "${var.num_nomad_clients}"
  desired_capacity = "${var.num_nomad_clients}"

  ami_id    = "${var.ami_id}"
  user_data = "${data.template_file.user_data_nomad_client.rendered}"

  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  ssh_key_name                = "${var.ssh_key_name}"
}

module "consul_iam_policies_clients" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.0.3"

  iam_role_id = "${module.nomad_clients.iam_role_id}"
}

data "template_file" "user_data_nomad_client" {
  template = "${file("${path.module}/user-data-nomad-client.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_name}"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}
