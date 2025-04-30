output "node_name" {
    value = local.node_name
}
output "node_public_ip" {
    value = module.create_application_node.instance_public_ip
}
output "node_private_ip" {
    value = module.create_application_node.instance_private_ip
}
output "node_instance_id" {
    value = module.create_application_node.instance_id
}