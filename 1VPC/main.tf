resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name        = "GS_VPC"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_internet_gateway" "Int_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "GS_IGW"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name        = "GS_Pub_Subnet"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Int_gw.id
    }

  tags = {
    Name        = "Pub_Rt"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_route_table_association" "pub_rt_asn" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_subnet" "pvt_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"

  tags = {
    Name        = "GS_Pvt_Subnet"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_route_table" "pvt_rt" {
    vpc_id = aws_vpc.main.id

  tags = {
    Name        = "Pvt_Rt"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_route_table_association" "pvt_rt_asn" {
  subnet_id      = aws_subnet.pvt_subnet.id
  route_table_id = aws_route_table.pvt_rt.id
}

resource "aws_subnet" "db_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.21.0/24"

  tags = {
    Name        = "GS_DB_Subnet"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_route_table" "db_rt" {
    vpc_id = aws_vpc.main.id

  tags = {
    Name        = "db_Rt"
    Terraform   = "true"
    Environmnet = "Dev"
  }
}

resource "aws_route_table_association" "db_rt_asn" {
  subnet_id      = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.db_rt.id
}

resource "aws_eip" "lb" {
  #instance = aws_instance.web.id
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.pub_subnet.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # depends_on = [aws_internet_gateway.example]
}

resource "aws_route" "pvt_r" {
  route_table_id            = aws_route_table.pvt_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.suneel.id
}

resource "aws_route" "db_r" {
  route_table_id            = aws_route_table.db_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  #vpc_peering_connection_id = "pcx-45ff3dc1"
  nat_gateway_id = aws_nat_gateway.suneel.id
}