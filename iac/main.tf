# Generate a random number to be attached to S3 bucket
resource "random_id" "random_id" {
  keepers = {
    key = "weather report"
  }
  byte_length = 8 # Generate an 8-byte random ID
}


#create s3 bucket to store weather data
resource "aws_s3_bucket" "weather_bucket" {
  bucket = "weather-bucket-${random_id.random_id.hex}"
  force_destroy = true

  tags = {
    Name = "Weather Bucket"
  }
}


#creates VPC
resource "aws_vpc" "weather_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Weather VPC"
  }
}


# Internet gateway to give the VPC access to the internet
resource "aws_internet_gateway" "weather_igw" {
  vpc_id = aws_vpc.weather_vpc.id

  tags = {
    Name = "Weather IGW"
  }
}


#Create public subnet
resource "aws_subnet" "weather_subnet" {
  vpc_id                  = aws_vpc.weather_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Weather Subnet"
  }
}


resource "aws_route_table" "weather_route_table" {
  vpc_id = aws_vpc.weather_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.weather_igw.id
  }

  tags = {
    Name = "Weather Route Table"
  }
}


# Associate the route table with a subnet
resource "aws_route_table_association" "weather_rta" {
  subnet_id      = aws_subnet.weather_subnet.id
  route_table_id = aws_route_table.weather_route_table.id
}

resource "aws_security_group" "weather_sg" {
  name        = "Weather SG"
  description = "Weather SG"
  vpc_id      = aws_vpc.weather_vpc.id
  tags = {
    Name = "Weather SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "weather_sg_ir" {
  security_group_id = aws_security_group.weather_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}


resource "aws_vpc_security_group_egress_rule" "weather_sg_er" {
  security_group_id = aws_security_group.weather_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json

  tags = {
    tag-key = "EC2 IAM Role"
  }
}

data "aws_secretsmanager_secret" "secret_manager" {
  name = "OpenWeatherAppSecret"
}

data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "${aws_s3_bucket.weather_bucket.arn}",
      "${aws_s3_bucket.weather_bucket.arn}/*",
      data.aws_secretsmanager_secret.secret_manager.arn
    ]
  }
}


resource "aws_iam_policy" "weather_iam_role_policy" {
  name   = "weather_iam_role_policy"
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.weather_iam_role_policy.arn
}


resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}



data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "ec2_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.weather_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = "EC2_SSH_Key_pair"
  vpc_security_group_ids = [aws_security_group.weather_sg.id]

  tags = {
    Name = "EC2 Server"
  }
}


resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id       = aws_vpc.weather_vpc.id
  service_name = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids = [aws_route_table.weather_route_table.id]
}


