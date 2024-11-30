# Define the provider (here - AWS) and its version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Define the region in which AWS resources will 'physically' be created,
# optionally add a profile name (from the file .aws/credentials)
provider "aws" {
  region = "us-east-1"
  profile = var.credentials_profile
}

resource "aws_iam_policy" "ci_cd_policies" {
  name   = "CI-CD_group_policies"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect  = "Allow"
      Action  = [
        "autoscaling:AttachLoadbalancers",
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:DetachLoadbalancers",
        "autoscaling:DeleteAutoScalingGroup",
        "autoscaling:CreateLaunchConfiguration",
        "autoscaling:DeleteLaunchConfiguration",
        "ec2:CreateNetworkAcl",
        "ec2:CreateNetworkAclEntry",
        "ec2:DescribeNetworkAcls",
        "ec2:ReplaceNetworkAclAssociation",
        "ec2:DeleteNetworkAcl",
        "ec2:DeleteNetworkAclEntry",
        "ec2:CreateNetworkInterface",
        "ec2:AttachNetworkInterface",
        "ec2:DescribeTags",
        "ec2:DescribeNetworkInterfaces",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:DescribeInstanceTypes",
        "ec2:ModifySubnetAttribute",
        "ec2:DetachNetworkInterface",
        "ec2:DescribeInstanceCreditSpecifications",
        "ec2:DescribeInstanceAttribute",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeVpcClassicLinkDnsSupport",
        "ec2:CreateVpc",
        "ec2:DescribeRouteTables",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeVpcs",
        "ec2:ModifyVpcAttribute",
        "ec2:DeleteVpc",
        "ec2:CreateVpcEndpoint",
        "ec2:DescribeVpcEndpoints",
        "ec2:ModifyVpcEndpoint",
        "ec2:DeleteVpcEndpoints",
        "ec2:CreateVpcPeeringConnection",
        "ec2:AcceptVpcPeeringConnection",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeVpcClassicLink",
        "ec2:DeleteVpcPeeringConnection",
        "ec2:CreateSubnet",
        "ec2:DescribeSubnets",
        "ec2:DeleteSubnet",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:RunInstances",
        "ec2:MonitorInstances",
        "ec2:DescribeImages",
        "ec2:DescribeVolumes",
        "ec2:DescribeInstances",
        "ec2:ModifyInstanceAttribute",
        "ec2:TerminateInstances",
        "ec2:UnmonitorInstances",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DescribeSecurityGroups",
        "ec2:DeleteSecurityGroup",
        "ec2:CreateInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DescribeInternetGateways",
        "ec2:DetachInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:CreateRouteTable",
        "ec2:EnableVGWRoutePropagation",
        "ec2:DisassociateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:AllocateAddress",
        "ec2:AssociateAddress",
        "ec2:DescribeAddresses",
        "ec2:ReleaseAddress",
        "ec2:DisassociateAddress",
        "ec2:ReplaceRouteTableAssociation",
        "ec2:AssociateRouteTable",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "elasticloadbalancing:DescribeInstanceHealth",
        "elasticloadbalancing:ApplySecurityGroupsToLoadbalancer",
        "elasticloadbalancing:ConfigureHealthCheck",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancerListeners",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:DescribeLoadBalancerAttributes",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeTags",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancerListeners",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RemoveTags",
        "route53:ChangeResourceRecordSets",
        "route53:GetHostedZone",
        "route53:ListResourceRecordSets",
        "route53:ChangeTagsForResource",
        "route53:CreateHealthCheck",
        "route53:GetHealthCheck",
        "route53:ListTagsForResource",
        "route53:UpdateHealthCheck",
        "route53:DeleteHealthCheck",
        "rds:Describe*",
        "rds:AddTagsToResource",
        "rds:ListTagsForResource",
        "rds:CreateDBInstance",
        "rds:StartDBInstance",
        "rds:StopDBInstance",
        "rds:DeleteDBInstance",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:CreateDBSnapshot",
        "rds:RestoreDBInstanceFromDBSnapshot",
        "iam:AddRoleToInstanceProfile",
        "iam:CreateInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:GetInstanceProfile",
        "iam:PassRole",
        "iam:ListRolePolicies",
        "iam:ListInstanceProfilesForRole",
        "iam:ListAttachedRolePolicies"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_group" "ci_cd_group" {
  name = "ci-cd"
}

resource "aws_iam_group_policy_attachment" "ci_cd_group_policies_attach" {
  group      = aws_iam_group.ci_cd_group.name
  policy_arn = aws_iam_policy.ci_cd_policies.arn
}
