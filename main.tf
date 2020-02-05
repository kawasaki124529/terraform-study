module "dev_server" {
  source = "./http_server"
  instance_type = "t3.micro"
}

module "describe_regions_for_ec2" {
  source = "./iam_role"
  name = "describe-regionsfor-ec2"
  identifier = "ec2.amazonaws.com"
  policy = "data.aws_iam_policy_document.allow.describe.json"
}

output "public_dns" {
  value = module.dev_server.public_dns
}

