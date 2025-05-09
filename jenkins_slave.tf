# Criar grupo de segurança
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow-ssh-"

  ingress {
    description = "Allow SSH"
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
}

# Criar a instância EC2 com chave existente e script de inicialização
resource "aws_instance" "Jenkins-slave" {
  ami           = "ami-0c7af5fe939f2677f"
  instance_type = "t3.micro"
  key_name      = "xp"
  security_groups = [aws_security_group.allow_ssh_http.name]

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ec2-user/.ssh
    echo "${var.public_key}" >> /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
    chown -R ec2-user:ec2-user /home/ec2-user/.ssh
  EOF

  tags = {
    Name = "slave"
  }
}
