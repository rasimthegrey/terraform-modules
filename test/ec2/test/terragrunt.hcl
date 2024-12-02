include {
  path = find_in_parent_folders()
}

locals {
  common_vars            = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name                   = "ec2"
  ami                    = "ami-0084a47cc718c111a"
  instance_type          = "t2.micro"
  encrypted              = true
  root_block_volume_type = "gp3"
  root_block_volume_size = 20
}

terraform {
  source = "../../..//modules/terraform-aws-ec2-instance"
}

inputs = {
  name                   = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  ami                    = local.ami
  instance_type          = local.instance_type
  vpc_security_group_ids = [dependency.sg_ec2.outputs.security_group_id]
  iam_instance_profile   = dependency.ssm_role.outputs.iam_instance_profile_name
  subnet_id              = dependency.vpc.outputs.public_subnets[0]
  root_block_device = [
    {
      encrypted   = local.encrypted
      volume_type = local.root_block_volume_type
      volume_size = local.root_block_volume_size
    }
  ]
  tags = local.common_vars.tags
}


dependency "vpc" {
  config_path = "../../vpc"
}

dependency "sg_ec2" {
  config_path = "../../security-group/ec2"
}

dependency "ssm_role" {
  config_path = "../../iam/roles/ssm-role"
}
