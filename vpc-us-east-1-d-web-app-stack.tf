resource "aws_vpc" "web-app-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "web-app-vpc"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.hello-instance.id}"
  allocation_id = "${aws_eip.hello-eip.id}"
}

resource "aws_eip_association" "eip_assoc-1" {
  instance_id   = "${aws_instance.instance-1.id}"
  allocation_id = "${aws_eip.hello-eip-1.id}"
}

resource "aws_eip_association" "eip_assoc-2" {
  instance_id   = "${aws_instance.instance-2.id}"
  allocation_id = "${aws_eip.hello-eip-2.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.web-app-vpc.id}"

  tags {
    Name = "vpc-internet-gateway"
  }
}

resource "aws_default_route_table" "hello-route" {
  default_route_table_id = "${aws_vpc.web-app-vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "vpc-default-route-table"
  }
}

resource "aws_instance" "hello-instance" {
  #ami           = "ami-1853ac65"
  #ami           = "ami-c09e43bf"
  ami = "ami-0a7fdb75"

  connection = {
    user        = "ec2-user"
    private_key = "${file("~/Documents/hello.pem")}"
  }

  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.us-east-1a-public.id}"

  security_groups = [
    "${aws_security_group.allow_all.id}",
  ]

  key_name = "hello"

  tags {
    Name = "hello-ec2-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /etc/init.d/nginx start",
    ]
  }
}

resource "aws_instance" "instance-1" {
  #ami           = "ami-1853ac65"
  #ami           = "ami-c09e43bf"
  ami = "ami-0a7fdb75"

  connection = {
    user        = "ec2-user"
    private_key = "${file("~/Documents/hello.pem")}"
  }

  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.us-east-1a-public.id}"

  security_groups = [
    "${aws_security_group.allow_all.id}",
  ]

  key_name = "hello"

  tags {
    Name = "hello-ec2-instance-1"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /etc/init.d/nginx start",
    ]
  }
}

resource "aws_instance" "instance-2" {
  #ami           = "ami-1853ac65"
  #ami           = "ami-c09e43bf"
  ami = "ami-0a7fdb75"

  connection = {
    user        = "ec2-user"
    private_key = "${file("~/Documents/hello.pem")}"
  }

  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.us-east-1a-public.id}"

  security_groups = [
    "${aws_security_group.allow_all.id}",
  ]

  key_name = "hello"

  tags {
    Name = "hello-ec2-instance-2"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /etc/init.d/nginx start",
    ]
  }
}

resource "aws_subnet" "us-east-1a-public" {
  vpc_id            = "${aws_vpc.web-app-vpc.id}"
  cidr_block        = "10.0.1.0/25"
  availability_zone = "us-east-1a"

  tags {
    Name = "${var.subnet-name}"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow https, http traffic"
  vpc_id      = "${aws_vpc.web-app-vpc.id}"

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

resource "aws_eip" "hello-eip-1" {
  vpc = true
}

resource "aws_eip" "hello-eip-2" {
  vpc = true
}

# Create a new load balancer 
resource "aws_elb" "bar" {
  name = "foobar-terraform-elb"

  # availability_zones = ["us-east-1a"]

  subnets = ["${aws_subnet.us-east-1a-public.id}"]
  security_groups = [
    "${aws_security_group.allow_all.id}",
  ]
  access_logs {
    bucket = "elb-logs-ram-1"

    # bucket_prefix = "bar"
    interval = 60
  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # listener {
  #   instance_port      = 8000
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  # }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances                   = ["${aws_instance.hello-instance.id}", "${aws_instance.instance-1.id}", "${aws_instance.instance-2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  tags {
    Name = "foobar-terraform-elb"
  }
}
