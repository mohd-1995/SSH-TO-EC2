resource "aws_vpc" "mb_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "mb_public_subnet" {
  vpc_id                  = aws_vpc.mb_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "dev_public "
  }
}


resource "aws_internet_gateway" "mb_internet_gateway" {
  vpc_id = aws_vpc.mb_vpc.id

  tags = {
    Name = "Dev-igw"
  }
}

resource "aws_route_table" "mb_public_rt" {
  vpc_id = aws_vpc.mb_vpc.id

  tags = {
    Name = "dev-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mb_public_rt.id
  destination_cidr_block = "0.0.0.0/16"
  gateway_id             = aws_internet_gateway.mb_internet_gateway.id

}

resource "aws_route_table_association" "mb_public_assc" {
  subnet_id      = aws_subnet.mb_public_subnet.id
  route_table_id = aws_route_table.mb_public_rt.id

}


resource "aws_security_group" "mb_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mb_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_key_pair" "mb_auth" {
  key_name   = "mb_keys"
  public_key = file("~/.ssh/mbkey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.mb_ami.id
  key_name               = aws_key_pair.mb_auth.id
  vpc_security_group_ids = [aws_security_group.mb_sg.id]
  subnet_id              = aws_subnet.mb_public_subnet.id
  user_data = file("Userdata.tpl")

  root_block_device {
    volume_size = 10

  }

  tags = {
    Name = "dev-node"
  }

  provisioner "local-exec" {
   command = templatefile("${var.host_as}-ssh-config.tpl", {
    hostname = self.public_ip
    user = "mo_b"
    identifyfile = "~/.ssh/mbkey"
   })
   interpreter = var.host_as == "windows" ? ["Bash", "-c"] : ["PowerShell", "-command"]
  }
}

