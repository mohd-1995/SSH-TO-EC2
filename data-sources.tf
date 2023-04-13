data "aws_ami" "mb_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.20230329.0-kernel-6.1-x86_64"]

  }
}