resource "aws_docdb_cluster" "main" {
  cluster_identifier      = "${local.prefix}-docdb"
  engine                  = var.engine
  engine_version          = var.engine_version
  master_username         = data.aws_ssm_parameter.username.value
  master_password         = data.aws_ssm_parameter.password.value
  skip_final_snapshot     = true
  storage_encrypted       = true
  vpc_security_group_ids  = [aws_security_group.main.id]
  db_subnet_group_name    = aws_docdb_subnet_group.main.name
}


resource "aws_docdb_cluster_parameter_group" "main" {
  family      = var.parameter_group_family
  name        = "${local.prefix}-docdb"
  tags        = merge(var.tags, { Name = "${local.prefix}-docdb"})

}

resource "aws_docdb_subnet_group" "main" {
  name       = "${local.prefix}-docdb"
  subnet_ids = var.subnets

  tags = {
    Name = "${local.prefix}-docdb"
  }
}


resource "aws_security_group" "main" {
  name        = "${local.prefix}-docdb-security-group"
  description = "${local.prefix}-docdb-security-group"
  vpc_id      =  var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = var.sg_cidrs
    description      = "DOCDB"
  }

  tags = merge (var.tags, {
    Name = "${local.prefix}-docdb-sg"
  })
}


resource "aws_docdb_cluster_instance" "main" {
  count              = var.instance_count
  identifier         = "${local.prefix}-docdb-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.main.id
  instance_class     = var.instance_class
}