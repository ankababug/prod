provider "aws" {
  region  = var.aws-region
  access_key=var.access
  secret_key=var.secret
}

resource "aws_vpc" "prod-vpc" {
  cidr_block       = var.vpc-cidr
  instance_tenancy = var.tenancy
  enable_dns_hostnames= true

  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}

resource "aws_subnet" "pub-sub" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = var.sub-cidrs
  availability_zone= "ap-south-1a"
  map_public_ip_on_launch= true
  tags = {
    Name = "pub-sub"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }


  tags = {
    Name = "pub-rt"
  }
}

resource "aws_route_table_association" "ass" {
  subnet_id      = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.pub-rt.id
}


resource "aws_security_group" "ssh-sg" {
  name        = "ssh-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "prod-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz68Zyg/rnFz9kANqm6xkETQ40+SXdFSVwClwEb3M7XHXwhorTF2VoibrTMyDDvOD3ZmLVLHZVsmuRSFg/yuMCudCFvzytUFAhYMgMGrKPnCjr0mdiwz6nh5MZzWgojkkPUOwbv+/huhTyVcU1EUtPv9NDDftEqRofN32UIndns/Lm/xtBQsedD9262pugEhjOYOUb8RaLeDQ0RVVjBm3EbvvUmmGHmoUtl9WG8I3KRhB8Xf4jNb0NW45kkfCKkbXD6ZOB7JVSs+lG0NRxmoEAXNhttH+nzrEA6DYIcOsJu72lZ0g6nH0HOZO4LTXzx14oJ1hgNEegCqZn1wEs4NSn root@ip-172-31-41-174"
}

resource "aws_instance" "web1" {
  ami           = "ami-02913db388613c3e1"
  instance_type = "t2.micro"
  availability_zone= "ap-south-1a"
  key_name= aws_key_pair.deployer.id
  subnet_id= aws_subnet.pub-sub.id
  security_groups= ["sg-0630da8dcd34ba8a9"] 
  associate_public_ip_address= true

  tags = {
    Name = "HelloWorld"
  }
}

resource "random_id" "bucket" {
    count = 2
    byte_length= 2
}

resource "aws_s3_bucket" "b" {
  bucket = "tf-bucket-${random_id.bucket.*.dec[0]}"
  acl    = "private"

  tags = {
    Name        = "bucket-${random_id.bucket.*.dec[0]}"
  }
}

resource "aws_elb" "bar" {
  name               = "foobar-terraform-elb-1"
  subnets            = [aws_subnet.pub-sub.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "http:80/"
    interval            = 30
  }

  instances                   = [aws_instance.web1.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb-1"
  }
}
