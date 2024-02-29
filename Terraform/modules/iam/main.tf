resource "aws_iam_user" "myiamuser" {
  name = var.user
}

resource "aws_iam_access_key" "myiamaccesskey" {
  user = aws_iam_user.myiamuser.name
}

resource "aws_iam_role" "myiamrole" {
  name               = var.role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = var.ec2_service_principal
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "myiampolicy" {
  name        = var.policy
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = var.policy_actions,
        Resource  = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "myiamrolepolicyattachment" {
  role       = aws_iam_role.myiamrole.name
  policy_arn = aws_iam_policy.myiampolicy.arn
}