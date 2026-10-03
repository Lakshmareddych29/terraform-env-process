resource "aws_iam_role" "ssm" {
  name = "${var.instance_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.instance_name}-ssm-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.instance_name}-ssm-profile"
  role = aws_iam_role.ssm.name
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    LOG_FILE="/var/log/user-data.log"
    exec > >(tee -a "$LOG_FILE") 2>&1

    echo "========================================"
    echo "Starting EC2 bootstrap"
    echo "========================================"

    # --------------------------------------------------
    # Wait for network/NAT connectivity
    # --------------------------------------------------

    echo "Waiting for network connectivity..."

    NETWORK_READY=false

    for i in {1..30}; do
      if curl -fsS --max-time 5 https://archive.ubuntu.com >/dev/null 2>&1; then
        echo "Network connectivity is available."
        NETWORK_READY=true
        break
      fi

      echo "Network not ready. Attempt $i/30. Waiting 10 seconds..."
      sleep 10
    done

    if [ "$NETWORK_READY" = false ]; then
      echo "ERROR: Internet connectivity was not available."
      exit 1
    fi

    # --------------------------------------------------
    # Update packages
    # --------------------------------------------------

    echo "Updating package repository..."

    apt-get update -y

    # --------------------------------------------------
    # Install Nginx
    # --------------------------------------------------

    echo "Installing Nginx..."

    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx

    # --------------------------------------------------
    # Enable and start Nginx
    # --------------------------------------------------

    echo "Starting Nginx..."

    systemctl enable nginx
    systemctl start nginx

    # --------------------------------------------------
    # Deploy application
    # --------------------------------------------------

    echo "Deploying application..."

    cat > /var/www/html/index.html <<'HTML'
    ${file("${path.module}/../../application/index.html")}
    HTML

    # --------------------------------------------------
    # Restart Nginx
    # --------------------------------------------------

    echo "Restarting Nginx..."

    systemctl restart nginx

    # --------------------------------------------------
    # Install / start AWS SSM Agent
    # --------------------------------------------------

    echo "Configuring AWS Systems Manager Agent..."

    snap install amazon-ssm-agent --classic || true

    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true

    systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true

    # --------------------------------------------------
    # Verify Nginx
    # --------------------------------------------------

    echo "Checking Nginx..."

    systemctl is-active --quiet nginx

    echo "Nginx is running successfully."

    echo "========================================"
    echo "EC2 bootstrap completed successfully"
    echo "========================================"
  EOF

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = var.instance_name
    }
  )
}