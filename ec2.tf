# ---------------------------
# EC2 Instance
# ---------------------------
resource "aws_instance" "master" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = "m5.xlarge"
  subnet_id                   = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
    tags = {
      Name = "${var.project}-master-root-volume"
      User = var.user
    }
  }

  key_name = var.keypair

  tags = {
    Name = "${var.project}-master-ec2"
    User = var.user
  }
  user_data = <<-EOF
    #!/bin/bash
    set -eux
    
    LOG=/var/log/user-data.log
    exec > >(tee -a "$LOG") 2>&1
    
    echo "[$(date)] ==== Start User Data Script ===="
    
    echo "[$(date)] Downloading Zabbix repo package..."
    wget -q https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb
    
    echo "[$(date)] Installing Zabbix repo package..."
    dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb
    
    echo "[$(date)] Updating apt cache..."
    apt-get update -y
    
    echo "[$(date)] Installing core packages..."
    apt-get install -y \
      zabbix-server-mysql \
      zabbix-frontend-php \
      zabbix-apache-conf \
      zabbix-sql-scripts \
      zabbix-agent2 \
      mysql-server
    if dpkg -s zabbix-server-mysql >/dev/null 2>&1; then
      echo "[$(date)] zabbix-server-mysql installed"
    else
      echo "[$(date)] zabbix-server-mysql installation FAILED" >&2
      exit 1
    fi
    
    echo "[$(date)] Installing agent2 plugins..."
    apt-get install -y \
      zabbix-agent2-plugin-mongodb \
      zabbix-agent2-plugin-mssql \
      zabbix-agent2-plugin-postgresql
    
    if dpkg -s zabbix-agent2-plugin-postgresql >/dev/null 2>&1; then
      echo "[$(date)] zabbix-agent2-plugin-postgresql installed"
    else
      echo "[$(date)] zabbix-agent2-plugin-postgresql installation FAILED" >&2
      exit 1
    fi
    
    echo "[$(date)] ==== User Data Script Completed Successfully ===="
  EOF

}

output "master_public_ips" {
  description = "Public IP address of master-ec2"
  value       = aws_instance.master.public_ip
}

output "master_private_ips" {
  description = "Private IP address of master-ec2"
  value       = aws_instance.master.private_ip
}
