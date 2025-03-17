# Declarar variável para a chave pública
# export TF_VAR_public_key="$(cat ~/.ssh/id_ed25519.pub)"

variable "public_key" {
  description = "Chave pública SSH para acessar a instância"
  type        = string
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

# Criar a instância EC2 com chave existente e script de inicialização
resource "aws_instance" "master" {
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
    Name = "master"
  }
}
