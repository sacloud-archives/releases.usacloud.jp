variable server_admin_password {}

variable domain_name {
  default = "usacloud.jp"
}

variable subdomain_name {
  default = "staging"
}

variable subdomain_slack_name {
  default = "slack-staging"
}

variable simple_monitor_slack_webhook {
  default = ""
}

variable tags {
  type    = list(string)
  default = ["stage=production", "app=usacloud", "gen=3"]
}

locals {
  simple_monitor_notify_slack = "${var.simple_monitor_slack_webhook == "" ? false : true}"
  simple_monitor_notify_email = "${var.simple_monitor_slack_webhook == "" ? true : false}"
  fqdn                        = "${var.subdomain_name}.${var.domain_name}"
  slack_fqdn                  = "${var.subdomain_slack_name}.${var.domain_name}"
}
