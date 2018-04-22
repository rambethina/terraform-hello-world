resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.hello-instance.id}"
  allocation_id = "${aws_eip.hello-eip.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.hello-vpc.id}"

  tags {
    Name = "hello-igw"
  }
}

resource "aws_instance" "hello-instance" {
  #ami           = "ami-1853ac65"
  ami           = "ami-c09e43bf"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.us-east-1a-public.id}"

  security_groups = [
    "${aws_security_group.allow_all.id}",
  ]

  key_name = "hello"

  tags {
    Name = "hello-ec2-instance"
  }
}

resource "aws_vpc" "hello-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "hello-vpc"
  }

  #     tags {
  #     Name = "main"
  #   }
}

resource "aws_default_route_table" "hello-route" {
  #   vpc_id = "${aws_vpc.hello-vpc.id}"
  default_route_table_id = "${aws_vpc.hello-vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  #   route {
  #     ipv6_cidr_block = "::/0"
  #     egress_only_gateway_id = "${aws_egress_only_internet_gateway.foo.id}"
  #   }

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "us-east-1a-public" {
  vpc_id            = "${aws_vpc.hello-vpc.id}"
  cidr_block        = "10.0.1.0/25"
  availability_zone = "us-east-1a"

  tags {
    Name = "hello-subnet"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow https, http traffic"
  vpc_id      = "${aws_vpc.hello-vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSL access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSL access from anywhere
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "hello-eip" {
  vpc = true
}
