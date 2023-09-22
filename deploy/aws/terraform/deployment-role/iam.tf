#Create the deployment role
resource "aws_iam_role" "deployment-role" {
  name = local.role_name
  assume_role_policy = templatefile(
    "${path.module}/templates/iam_policies/assume-policy.tpl",
    {
      account-id    = var.account-id
    }
  )
  inline_policy {
    name = local.policy_name
    policy = templatefile(
      "${path.module}/templates/iam_policies/iam-policy.tpl", {}
    )
  }
  tags = var.default-tags
}

resource "aws_iam_policy" "extended-iam" {
  name        = local.iam_extended_policy_name
  description = "Additional terraform permissions"
  policy      = templatefile("${path.module}/templates/iam_policies/iam-policy-extended.tpl", {})
}

resource "aws_iam_policy_attachment" "additional_policy" {
  name       = "additional policy attachment"
  roles      = [aws_iam_role.deployment-role.name]
  policy_arn = aws_iam_policy.extended-iam.arn
}
