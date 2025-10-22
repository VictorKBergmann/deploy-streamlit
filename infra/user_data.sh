#!/bin/bash
# Atualiza e instala o Docker
apt-get update -y
apt-get install -y docker.io

# Inicia e habilita o Docker
systemctl start docker
systemctl enable docker

# Adiciona o usuário 'ubuntu' ao grupo 'docker'
# (AMI Ubuntu usa o usuário 'ubuntu' por padrão)
usermod -aG docker ubuntu

# Instala o Docker Compose (bônus, mas boa prática)
apt-get install -y docker-compose 