provider "aws" {

  region = "ap-south-1"
  profile = "default"

}


resource "aws_instance" "firstec2" {
  ami = "ami-0756a1c858554433e"
  instance_type = "t2.micro"
  key_name = "tf-test"
  subnet_id = "${aws_subnet.first.id}"
  tags = {
      Name = "CICD-Instance"
          }

  user_data = file("./install.sh")


}

resource "aws_instance" "secondec2" {
  ami = "ami-0756a1c858554433e"
  instance_type = "t2.medium"
  associate_public_ip_address = "false"
  key_name = "tf-test"
  subnet_id = "${aws_subnet.second.id}"
  tags = {
      Name = "Target-Instance"
          }

  user_data = file("./install2.sh")


}


resource "aws_vpc" "main" {
  cidr_block = "172.20.0.0/16"
  enable_dns_support = "1"
  enable_dns_hostnames = "1"
 tags = {
      Name = "myfirstvpc"
          }

}

resource "aws_subnet" "first" {
  availability_zone = "ap-south-1a"
  cidr_block = "172.20.10.0/24"
  map_public_ip_on_launch = "1"
  vpc_id = "${aws_vpc.main.id}"
  tags = {
      Name = "mypublicsubnet"
          }

}

resource "aws_subnet" "second" {
  availability_zone = "ap-south-1a"
  cidr_block = "172.20.20.0/24"
  map_public_ip_on_launch = "1"
  vpc_id = "${aws_vpc.main.id}"
  tags = {
      Name = "myprivatesubnet"
          }

}


resource "aws_default_security_group" "default_myfirst" {
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
  vpc_id = "${aws_vpc.main.id}"
  tags = {
      Name = "myfirstsecuritygroup"
          }

}

resource "aws_security_group" "publicsg" {
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.main.id}"
  tags = {
      Name = "publicsecuritygroup"
          }

}

resource "aws_security_group" "privatesg" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.main.id}"
  tags = {
      Name = "myfirstsecuritygroup"
          }

}

resource "aws_network_interface_sg_attachment" "publicsg_attachment" {
  security_group_id    = "${aws_security_group.publicsg.id}"
  network_interface_id = "${aws_instance.firstec2.primary_network_interface_id}"
}

resource "aws_network_interface_sg_attachment" "privatesg_attachment" {
  security_group_id    = "${aws_security_group.privatesg.id}"
  network_interface_id = "${aws_instance.secondec2.primary_network_interface_id}"
}


resource "aws_internet_gateway" "internet" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
      Name = "myinternetgateway"
          }

}

resource "aws_eip" "myeip" {
  vpc = true

}

resource "aws_nat_gateway" "natgw" {
   allocation_id = "${aws_eip.myeip.id}"
   subnet_id     = "${aws_subnet.first.id}"
   tags = {
       Name = "mynatgateway"
        }
}

resource "aws_route_table" "publicrt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet.id}"
  }

  tags = {
    Name = "Public RT"
  }
}

resource "aws_route_table" "privatert" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags = {
    Name = "Private RT"
  }
}



resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.first.id}"
  route_table_id = "${aws_route_table.publicrt.id}"
}



resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.second.id}"
  route_table_id = "${aws_route_table.privatert.id}"
}


output "IPs" {
  value = "CICD-Instance -  ${aws_instance.firstec2.public_ip} Target-Instance -  ${aws_instance.secondec2.private_ip}"
}

