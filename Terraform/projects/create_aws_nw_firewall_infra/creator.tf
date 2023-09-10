/**
Basic Requirements
------------------
Provider
    - Here we are using AWS : This will install aws modules in the `.terrform` directory
Auth (Creds)
    - Here we are using the aws configure creds (aws creds file) for authentication

**/

terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "4.21.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

/**

AWS Network Firewall Setup

Region:     us-east-1
VPC CIDR:   10.0.0.0/16
AZ:         us-east-1a


Create a 
 - Create 1 VPC: 
    P_VPC (CIDR: 10.0.0.0/16)
 - Create 1 Internet Gateway (IGW)
    
 - Create 2 Subnets:
    1 Subnet for Workload (Servers) Protected Subnet: 10.0.1.0/24
    1 Subnet for Firewall (Firewall Endpoint**) Firewall Subnet: 10.0.254.0/24
 - Create 1 Elastic IP
    For EC2 
 - Create 1 EC2 in `Protected Subnet`
    Associate with Protected Subnet
    Attach Elastic IP to it

 --------- Network Firewall -----------
 - Create Network Firewall Rule Group

 - Create Network Firewall Policy
    Attach Rule Group to Firewall
 
 - Create a Network Firewall
    Attach Policy to Firewall
 ---------------------------------------

 - Create 2 Route Table
    1 Route Table for Workload


**/

# VPC : P_VPC 
resource "aws_vpc" "P_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "P_VPC"
  }
}

# Internet Gateway: P_VPC_IGW
resource "aws_internet_gateway" "P_VPC_IGW" {
  vpc_id = aws_vpc.P_VPC.id

  tags = {
    Name = "P_VPC_IGW"
  }
}

# Subnet: Protected Subnet: 10.0.1.0/24
resource "aws_subnet" "P_VPC_Protected_Workload_Subnet" {
  vpc_id            = aws_vpc.P_VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "P_VPC_Protected_Workload_Subnet"
  }
}

# Subnet: Firewall Subnet: 10.0.254.0/24
resource "aws_subnet" "P_VPC_Firewall_Subnet" {
  vpc_id            = aws_vpc.P_VPC.id
  cidr_block        = "10.0.254.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "P_VPC_Firewall_Subnet"
  }
}

# KeyPair Required For EC2 Access
resource "aws_key_pair" "Access_Pair1" {
  key_name   = "Access_Pair1"
  public_key = "ssh-rsa ${var.SSH_KEY} WebServer"
}

# Security Group: WorkloadAccess_SG
resource "aws_security_group" "WorkloadAccess_SG" {
  name        = "WorkloadAccess_SG"
  description = "WorkloadAccess Security Group Instances Firewall"
  vpc_id      = aws_vpc.P_VPC.id

  ingress {
    description = "SSH From Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WorkloadAccess_SG"
  }
}

resource "aws_instance" "WorkerServer_1" {
  ami                         = "ami-0729e439b6769d6ab"
  instance_type               = "t2.micro"
  associate_public_ip_address = true # Elastic IP will be created in Version 2
  vpc_security_group_ids      = [aws_security_group.WorkloadAccess_SG.id]
  subnet_id                   = aws_subnet.P_VPC_Protected_Workload_Subnet.id
  key_name                    = aws_key_pair.Access_Pair1.id

  # Installing Ngnix Server and Creating a Simple HTML
  user_data = <<-EOL
  #!/bin/bash -xe
  apt-get update && apt-get upgrade -y
  apt-get install nginx -y
  echo "<h1>This is Website Host: [$(hostname)] and Added Code @ [$(date)] </h1>" > /var/www/html/index.nginx-debian.html
  EOL

  tags = {
    Name = "WorkerServer_1"

  }
}


/**** ---------------------------  **/

# AWS Network Firewall Rule Group: Stateful

resource "aws_networkfirewall_rule_group" "NWFWStatefulRuleGroup1" {
  capacity = 100
  name     = "NWFWStatefulRuleGroup1"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".example.com", ".whatsapp.net", ".whatsapp.com", ".badssl.com"]
      }
    }
  }

  tags = {
    Name = "NWFWStatefulRuleGroup1"
  }
}


resource "aws_networkfirewall_rule_group" "NWFWStatefulRuleGroup2" {
  capacity = 100
  name     = "NWFWStatefulRuleGroup2"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".yah.com", ".yahuasd.net", ".asds.com", ".asdsaa.com"]
      }
    }
  }

  tags = {
    Name = "NWFWStatefulRuleGroup2"
  }
}

# AWS Network Firewall Rule Group: Stateless

### Not Required for this setup


####################### Policy ###################

# AWS Firewall Policy: Statefull Policy
resource "aws_networkfirewall_firewall_policy" "NWFWALLPolicy1" {
  name = "NWFWALLPolicy1"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    #stateful_default_actions          = ["aws:block"]
    #stateful_fragment_default_actions = ["aws:block"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.NWFWStatefulRuleGroup1.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.NWFWStatefulRuleGroup2.arn
    }
  }

  tags = {
    Name = "NWFWALLPolicy1"
  }
}

/** AWS Network Firewall Creation **/
resource "aws_networkfirewall_firewall" "NWFW" {
  name                = "NWFW"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.NWFWALLPolicy1.arn
  vpc_id              = aws_vpc.P_VPC.id
  subnet_mapping {
    subnet_id = aws_subnet.P_VPC_Firewall_Subnet.id
  }

  tags = {
    Name = "NWFW"
  }
}

# AWS CloudWatch Log Group Creation

resource "aws_cloudwatch_log_group" "log_network_firewall_all" {
  name = "log_network_firewall_all"

  tags = {
    Name = "log_network_firewall_all"
  }
}

# Logging
resource "aws_networkfirewall_logging_configuration" "NW_FW_Logging" {
  firewall_arn = aws_networkfirewall_firewall.NWFW.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.log_network_firewall_all.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.log_network_firewall_all.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}


# AWS NW FW Logging Configuration

/**
# Alert Logs
resource "aws_networkfirewall_logging_configuration" "NW_FW_Logging_Alert" {
  firewall_arn = aws_networkfirewall_firewall.NWFW.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.log_network_firewall_all.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}


resource "aws_cloudwatch_log_group" "log_network_firewall_all_flow" {
  name = "log_network_firewall_all_flow"

  tags = {
    Name = "log_network_firewall_all_flow"
  }
}

# Flow Logs
resource "aws_networkfirewall_logging_configuration" "NW_FW_Logging_Flow" {
  firewall_arn = aws_networkfirewall_firewall.NWFW.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.log_network_firewall_all_flow.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}
**/

## Output


output "network_firewall_vpcendpoint_id" {
  #value = aws_networkfirewall_firewall.NWFW.firewall_status.sync_states[0].attachment.endpoint_id
  value = tolist(aws_networkfirewall_firewall.NWFW.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
}


######## Route Settings ##########

# Create 3 Route Table

# IGW_Ingress_RT
resource "aws_route_table" "IGW_Ingress_RT" {
  vpc_id = aws_vpc.P_VPC.id

  route {
    cidr_block = "10.0.1.0/24"
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.NWFW.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
  }

  tags = {
    Name = "IGW_Ingress_RT"
  }
}

# IGW_Ingress_RT Association
resource "aws_route_table_association" "IGW_Ingress_RT_Edge_Association" {
  gateway_id     = aws_internet_gateway.P_VPC_IGW.id
  route_table_id = aws_route_table.IGW_Ingress_RT.id
}


# Firewall Subnet ID
resource "aws_route_table" "Firewall_Subnet_RT" {
  vpc_id = aws_vpc.P_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.P_VPC_IGW.id
  }

  tags = {
    Name = "Firewall_Subnet_RT"
  }
}

# Firewall_Subnet_RT Association
resource "aws_route_table_association" "Firewall_Subnet_RT_Association" {
  subnet_id     = aws_subnet.P_VPC_Firewall_Subnet.id
  route_table_id = aws_route_table.Firewall_Subnet_RT.id
}


# Workload Subnet ID
resource "aws_route_table" "Protected_Workload_Subnet_RT" {
  vpc_id = aws_vpc.P_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = tolist(aws_networkfirewall_firewall.NWFW.firewall_status[0].sync_states)[0].attachment[0].endpoint_id
  }

  tags = {
    Name = "Protected_Workload_Subnet_RT"
  }
}

# Protected_Workload_Subnet_RT Association
resource "aws_route_table_association" "Protected_Workload_Subnet_RT_Association" {
  subnet_id     = aws_subnet.P_VPC_Protected_Workload_Subnet.id
  route_table_id = aws_route_table.Protected_Workload_Subnet_RT.id
}


output "ec2_public_ip" {
  value = aws_instance.WorkerServer_1.public_ip
  description = "The Public IP address of the Worker Server Instance."
}