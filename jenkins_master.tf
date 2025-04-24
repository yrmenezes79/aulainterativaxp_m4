# Carregar a chave pública SSH a partir de um arquivo
locals {
  public_key = file("/root/.ssh/id_ed25519.pub")  
}

# Criar grupo de segurança
resource "aws_security_group" "allow_ssh_http" {
  name_prefix = "allow-ssh-http-"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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
}

# Criar instância EC2 com a chave pública e script de inicialização
resource "aws_instance" "my_instance" {
  ami                    = "ami-0c7af5fe939f2677f" # Substitua pela AMI da sua região
  instance_type          = "t3.micro"
  key_name               = "xp" # Nome da chave cadastrada no EC2
  security_groups        = [aws_security_group.allow_ssh_http.name]

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ec2-user/.ssh
    echo "${local.public_key}" >> /home/ec2-user/.ssh/authorized_keys
    chmod 600 /home/ec2-user/.ssh/authorized_keys
    chown -R ec2-user:ec2-user /home/ec2-user/.ssh
  EOF

  tags = {
    Name = "Master"
  }
}

# Output do IP público
output "public_ip" {
  description = "IP Público da instância EC2"
  value       = aws_instance.my_instance.public_ip
}

# Output do DNS público
output "public_dns" {
  description = "DNS Público da instância EC2"
  value       = aws_instance.my_instance.public_dns
}
