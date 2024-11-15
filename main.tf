provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "my_key" {
  key_name   = "id_rsa"
  public_key = file("/home/danilo/.ssh/id_rsa.pub")
}

# Security group para permitir http
resource "aws_security_group" "allow_http" {
  name_prefix = "allow_http_"

  ingress {
    from_port   = 80
    to_port     = 80
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

# Instancia con security group
resource "aws_instance" "web_server" {
  ami           = "ami-0866a3c8686eaeeba" # AMI de Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_http.id]

  provisioner "file" {
    source      = "./install.sh"
    destination = "/home/ubuntu/install.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/danilo/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install.sh",
      "/home/ubuntu/install.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/home/danilo/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "Web-Server-tf"
  }
}

# Ip publica de la instancia
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}