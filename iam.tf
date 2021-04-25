resource "aws_iam_policy" "allow-reading-into-instances-dir" {
  name = "Allow-Reading-Into-Instances-Dir"
  path = "/"
  description = "A policy to read into instances dir of saasproj bucket"
  policy = file("iam_policy/instance-read-saasproj-instances.json")

  tags = {
    project = "saas"
  }
}

resource "aws_iam_role" "instances-reader" {
  name = "instances-folder-reader"
  managed_policy_arns = [aws_iam_policy.allow-reading-into-instances-dir.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  permissions_boundary = "arn:aws:iam::357100702785:policy/Instance-SaaS-Boundaries"

  tags = {
    project = "saas"
  }
}

resource "aws_iam_instance_profile" "instances_profile" {
  name = "instances-profile"
  role = aws_iam_role.instances-reader.name
}
