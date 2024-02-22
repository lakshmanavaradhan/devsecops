provider "aws" {
  region = "us-east-1"
}

locals { 
value_vpc_id = var.vpc_id
value_keypair = var.keypair
value_ami_id = var.ami_id
}

terraform {
  required_version = ">= 0.14"
  backend "s3" {
    bucket = "lg-app-tfstate-5ec24429"
    key    = "state/tfstate"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "k8_bucket" {
  bucket = "k8-bucket-5ec24429"
  acl    = "private"
}

#best practice is to use s3 lifecycle to delete bucket
#copy spec file to s3
#filemd5 hash is the always better way to copy file, it better to you absolute path 
resource "aws_s3_bucket_object" "k8_spec" {
  bucket = aws_s3_bucket.k8_bucket.id 
  key    = "k8-spec.yaml"
  source = "k8-spec.yaml"
  depends_on = [aws_s3_bucket.k8_bucket]
}


#IAM policy
resource "aws_iam_policy" "s3_policy" {
  name        = "s3-policy-s3"
  description = "Access limited read obj from s3"
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
        {
            "Sid" = "s3",
            "Effect" = "Allow",
            "Action" = [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource" = "arn:aws:s3:::k8-bucket-5ec24429"
        },
        {
            "Sid" = "s3obj",
            "Effect" = "Allow",
            "Action" = [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource" = "arn:aws:s3:::k8-bucket-5ec24429/*"
        },
        ]
  })
}

#IAM ROLE
resource "aws_iam_role" "s3_role" {
  name = "s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}

# Attaching the IAM polixy to the role
 resource "aws_iam_policy_attachment" "s3_role_polciy_attachment" {
    name = "s3-policy-role-attachment"
    policy_arn = aws_iam_policy.s3_policy.arn
    roles = [ aws_iam_role.s3_role.name ]
 
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "app_profile"
  role = aws_iam_role.s3_role.name
}

# I am  not createing vpc, ig, subnet and nat for this project 

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security Group for SSH and HTTPS access"
  vpc_id      =  local.value_vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

# best practice to adding ec2 lifecycle
resource "aws_instance" "app_instance" {
  ami           = local.value_ami_id
  instance_type = "t3a.medium"
  key_name      = local.value_keypair
  security_groups      = [aws_security_group.app_sg.name]
  iam_instance_profile = aws_iam_instance_profile.app_profile.name
  root_block_device {
    volume_size = 30
  }
#better to use aws secerts render k8 spec file
  user_data = <<EOF
#!/bin/bash
sudo apt install snapd
sudo snap install microk8s --classic
sudo snap install aws-cli --classic
sudo aws s3 cp s3://k8-bucket-5ec24429/k8-spec.yaml /home/ubuntu/k8-spec.yaml
cd /home/ubuntu/
sudo touch one
echo "--service-node-port-range=0-65535" >> /var/snap/microk8s/current/args/kube-apiserver
sudo microk8s.stop
sudo microk8s.start
sudo microk8s.kubectl apply -f k8-spec.yaml
EOF
}

output "public_ip" {
  value = aws_instance.app_instance.public_ip
}
