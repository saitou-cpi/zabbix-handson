# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project}-ec2-sg"
  description = "handson ec2 sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "All traffic from myip"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.myip}"]
  }

  ingress {
    description = "All traffic from vpc"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-ec2-sg"
    User = var.user
  }
}
