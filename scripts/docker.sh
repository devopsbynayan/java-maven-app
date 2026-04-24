#!/bin/bash
set -e

echo "===== UPDATE SYSTEM ====="
apt-get update -y

echo "===== INSTALL DOCKER ====="
apt-get install -y docker.io

echo "===== ENABLE DOCKER SERVICE ====="
systemctl enable docker
systemctl start docker

echo "===== ADD USERS TO DOCKER GROUP ====="

# EC2 default user (ubuntu or root depending on AMI)
usermod -aG docker ubuntu || true
usermod -aG docker root || true

# Jenkins user (if exists)
id jenkins &>/dev/null && usermod -aG docker jenkins || true

echo "===== VERIFY INSTALLATION ====="
docker --version
systemctl status docker --no-pager

echo "===== DONE ====="
