# Create a VPC 
resource "aws_vpc" "vic" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "vic"
  }
}

# Create public_subnet
resource "aws_subnet" "public_subnet" {
  availability_zone = "us-east-1a"
  vpc_id            = aws_vpc.vic.id
  cidr_block        = var.public_subnet_cidr

  tags = {
    Name = "public_subnet"
  }
}

# Create public route_table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vic.id

  route {
    cidr_block = var.internet_cidr
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Create aws_internet_gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vic.id

  tags = {
    Name = "my_igw"
  }
}

# Create an association 
resource "aws_route_table_association" "public_route_table" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create private_subnet 
resource "aws_subnet" "private_subnet" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.vic.id
  cidr_block        = var.private_subnet_cidr

  tags = {
    Name = "private_subnet"
  }
}

# Create private route_table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vic.id
}

# Create an association 
resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id

}
# Create a security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vic.id

  tags = {
    Name = "allow_ssh"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = var.internet_cidr
  from_port         = 5439
  ip_protocol       = "tcp"
  to_port           = 5439
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = var.internet_cidr
  ip_protocol       = "-1"
}

# Create a Redshift Subnet Group
resource "aws_redshift_subnet_group" "victor_subnet_group" {
  name       = "victor-redshift-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]

  tags = {
    environment = "Production"
  }
}

# Create IAM role
resource "aws_iam_role" "redshift_role" {
  name = "redshift_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

# Create a policy
resource "aws_iam_role_policy" "redshift_policy" {
  name = "redshift_policy"
  role = aws_iam_role.redshift_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListAllBuckets",
          "redshift:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

#Create the cluster 
resource "aws_redshift_cluster" "redshift_job" {
  cluster_identifier = "vic-redshift-cluster"
  database_name      = "victordb"
  master_username    = "victor"
  node_type          = "dc1.large"
  cluster_type       = "multi-node"
  number_of_nodes    = 3

  manage_master_password = true
}

