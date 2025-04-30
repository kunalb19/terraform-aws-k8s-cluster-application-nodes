module "create_application_node" {
  source                      = "kmayer10/create-ec2/aws"
  version                     = "1.0.1"
  ami                         = var.application_node.ami
  instance_type               = var.application_node.instance_type
  key_name                    = var.application_node.key_name
  associate_public_ip_address = var.application_node.associate_public_ip_address
  vpc_security_group_ids      = var.application_node.vpc_security_group_ids
  subnet_id                   = var.application_node.subnet_id
  tags                        = var.application_node.tags
  user_data                   = var.application_node.user_data
  private_key_file            = var.application_node.private_key_file
  private_key                 = var.application_node.private_key
}

resource "null_resource" "copy_and_run_join_command_on_application_node" {
  depends_on = [
    module.create_application_node
  ]
  provisioner "remote-exec" {
    inline = [
      "scp -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /tmp/join_command.sh ${var.application_node.user}@${module.create_application_node.instance_private_ip}:/tmp/join_command.sh",
      "echo ${module.create_application_node.instance_private_ip} >> ~/hosts",
      "ansible ${module.create_application_node.instance_private_ip} -i ~/hosts -m shell -a 'sudo bash /tmp/join_command.sh' --private-key ~/.ssh/id_rsa --user ${var.application_node.user} --become"
    ]
    connection {
      type        = "ssh"
      host        = var.control_plane.host
      user        = var.control_plane.user
      private_key = var.control_plane.private_key
    }
  }
}

locals {
  ip           = split(".", module.create_application_node.instance_private_ip)
  node_name      = "ip-${local.ip[0]}-${local.ip[1]}-${local.ip[2]}-${local.ip[3]}"
}

resource "kubernetes_node_taint" "thinknyx_1" {
  count = var.taint.taint_required == true ? 1 : 0
  metadata {
    name = local.node_name
  }
  taint {
    key    = var.taint.key
    value  = var.taint.value
    effect = var.taint.effect
  }
}