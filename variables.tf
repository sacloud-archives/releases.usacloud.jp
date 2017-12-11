variable server_admin_password {}

variable webhook_user {}
variable webhook_password {}
variable slack_token {}

variable domain_name {
  default = "usacloud.jp"
}

variable subdomain_name {
  default = "staging"
}

variable front_web_server_spec {
  type = "map"

  default = {
    core   = 1
    memory = 1
  }
}

variable front_web_server_count {
  default = 1
}

variable simple_monitor_slack_webhook {
  default = ""
}

variable front_private_network_ip {
  default = "192.168.100.0"
}

variable front_private_network_mask {
  default = 24
}

variable front_private_ip_offset {
  default = 11
}

variable nfs_private_ip {
  default = "192.168.100.101"
}

locals {
  front_ip_range              = "${format("%s/%s" , var.front_private_network_ip ,var.front_private_network_mask)}"
  simple_monitor_notify_slack = "${var.simple_monitor_slack_webhook == "" ? false : true}"
  simple_monitor_notify_email = "${var.simple_monitor_slack_webhook == "" ? true : false}"
  fqdn                        = "${var.subdomain_name}.${var.domain_name}"
}
