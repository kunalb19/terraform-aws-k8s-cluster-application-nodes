variable "application_node" {
  type = object({
    ami                         = string
    instance_type               = string
    key_name                    = string
    associate_public_ip_address = optional(bool, true)
    vpc_security_group_ids      = list(string)
    subnet_id                   = string
    tags                        = map(string)
    user_data                   = string
    private_key_file            = string
    private_key                 = string
    user                        = optional(string, "ubuntu")
  })
}
variable "control_plane" {
  type = object({
    host        = string
    private_key = string
    user        = optional(string, "ubuntu")
  })
}
variable "taint" {
    type = object({
      taint_required = optional(bool, false)
      key            = string
      value          = string
      effect         = optional(string, "NoSchedule")
    })
}