terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group (Firewall)
resource "aws_security_group" "streamlit_sg" {
  name        = "streamlit-sg"
  description = "Permite SSH e Streamlit (8501)"

  # SSH (Porta 22) - Restrinja ao seu IP se possível
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ABERTO P/ O MUNDO (Apenas para o MVP)
  }

  # Streamlit (Porta 8501)
  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ABERTO P/ O MUNDO
  }

  # Regra de saída (permite baixar pacotes e imagens Docker)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# server
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

# Instância EC2
resource "aws_instance" "app_server" {
  # AMI do Ubuntu 22.04 LTS (Free Tier) na us-east-1
  # (Se mudar a região, encontre a AMI correta)
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  # Anexa o Security Group
  vpc_security_group_ids = [aws_security_group.streamlit_sg.id]

  # Anexa a Key Pair SSH
  key_name = var.key_pair_name

  # Roda o script de instalação do Docker
  user_data = file("user_data.sh")

  tags = {
    Name = "Servidor-Streamlit"
  }
}