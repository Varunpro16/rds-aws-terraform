# Specify provider
provider "aws" {
  region = "us-west-2"  # Change this to your preferred region
}

# Define a security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow inbound traffic for PostgreSQL"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-postgres-subnet-group"
  description = "RDS subnet group"
  subnet_ids = ["subnet-033079b2d5b18dca2" ,"subnet-0bd9b1cff9a9ef6d8"]  # Replace with your subnet IDs

  tags = {
    Name = "rds-postgres-subnet-group"
  }
}

# Create RDS instance
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type           = "gp3"
  engine               = "postgres"
  engine_version       = "16.6"  # Replace with your preferred version
  instance_class       = "db.t3.micro"  # Adjust based on your requirements
  db_name               = "mydatabase"  # Database name
  username             = "adminuser"       # Master username
  password             = "adminpass"  # Replace with a strong password
  # parameter_group_name = "default.postgres14"
  publicly_accessible  = true  # Set to false if not required
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  
  # BACKUP CONFIGURATION
  # backup_retention_period = 7
  # storage_encrypted       = true
  
  skip_final_snapshot     = true


  tags = {
    Name = "rds-postgres-instance"
  }
}

# Output database endpoint
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}
