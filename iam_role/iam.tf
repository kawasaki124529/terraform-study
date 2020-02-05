variable "name" {}
variable "policy" {}
variable "identifier" {}

resource "aws_iam_role" "default" {
  name = var.name
  assume_role_policy  data.aws.iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifier = [var.identifier]
    }
  }
}

resource "aws_iam_policy" "default" {
  name = var.name
  policy_arn = aws_iam_policy.default.arn
}

output "iam_role_arn" {
  value = aws_iam_role.default.arn
}

output "iam_role_name" {
  value = aws_iam_role.default.name
}
