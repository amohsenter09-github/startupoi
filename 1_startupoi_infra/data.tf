## This is just for documentation perference - This is a copied snapshoot from dev-Zulip in ap-southeast-1 to eu-west-1
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


data "aws_ebs_snapshot" "dev-zulip-snap" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["dev-Zulip-snap"]
  }
}

## This is just for documentation perference - This is a copied snapshoot from dev-jobsearchservice in ap-southeast-1 to eu-west-1
data "aws_ebs_snapshot" "jobsearchservice" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["dev-jobsearchservice-snap"]
  }
}

