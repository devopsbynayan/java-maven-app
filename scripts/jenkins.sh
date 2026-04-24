#!/bin/bash
set -e

echo "===== FULL CLEANUP ====="

systemctl stop jenkins 2>/dev/null || true
apt purge -y jenkins || true
apt autoremove -y

rm -rf /var/lib/jenkins
rm -rf /etc/jenkins
rm -rf /var/log/jenkins
rm -rf /var/cache/jenkins

rm -f /etc/apt/sources.list.d/jenkins.list
rm -f /usr/share/keyrings/jenkins-keyring.asc
rm -f /etc/apt/trusted.gpg.d/jenkins.gpg

echo "===== SYSTEM UPDATE ====="
apt update -y

echo "===== INSTALL JAVA 21 (REQUIRED) ====="
apt install -y openjdk-21-jdk

# Force Java 21 system-wide
update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac

echo "===== ADD JENKINS REPO (WORKING METHOD) ====="

apt install -y gnupg curl

gpg --keyserver keyserver.ubuntu.com --recv-keys 7198F4B714ABFC68
gpg --export 7198F4B714ABFC68 | tee /etc/apt/trusted.gpg.d/jenkins.gpg > /dev/null

echo "deb https://pkg.jenkins.io/debian binary/" > /etc/apt/sources.list.d/jenkins.list

apt update -y

echo "===== INSTALL JENKINS ====="
apt install -y jenkins

echo "===== FORCE JAVA 21 IN SERVICE ====="

sed -i 's|Environment="JAVA_HOME=.*"|Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"|' /usr/lib/systemd/system/jenkins.service || true

echo 'Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"' >> /usr/lib/systemd/system/jenkins.service

systemctl daemon-reload
systemctl daemon-reexec

echo "===== START JENKINS ====="
systemctl enable jenkins
systemctl start jenkins

echo "===== STATUS ====="
systemctl status jenkins --no-pager

echo "===== ADMIN PASSWORD ====="
cat /var/lib/jenkins/secrets/initialAdminPassword

echo "===== DONE ====="
echo "Open: http://<EC2-IP>:8080"
