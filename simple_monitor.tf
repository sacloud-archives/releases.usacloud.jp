resource sakuracloud_simple_monitor "node-health" {
  count  = "${var.front_web_server_count}"
  target = "${sakuracloud_server.front.*.ipaddress[count.index]}"

  health_check = {
    protocol   = "ping"
    delay_loop = 60
  }

  notify_email_enabled = "${local.simple_monitor_notify_email}"
  notify_email_html    = "${local.simple_monitor_notify_email}"
  notify_slack_enabled = "${local.simple_monitor_notify_slack}"
  notify_slack_webhook = "${var.simple_monitor_slack_webhook}"

  description = "Simple-Monitor for ${local.fqdn} front web-servers[${sakuracloud_server.front.*.name[count.index]}:${sakuracloud_server.front.*.ipaddress[count.index]}]"
  tags        = ["production", "simple-monitor", "usacloud"]
  icon_id     = "${sakuracloud_icon.icon.id}"
}

locals {
  monitoring_targets = [
    "/status.html",
    "/usacloud/status.html",
    "/terraform/status.html",
    "/docker-machine/status.html",
  ]
}

resource sakuracloud_simple_monitor "site-health" {
  target = "${local.fqdn}"
  count  = "${length(local.monitoring_targets)}"

  health_check = {
    protocol   = "https"
    delay_loop = 300
    path       = "${local.monitoring_targets[count.index]}"
    status     = "200"
  }

  notify_email_enabled = "${local.simple_monitor_notify_email}"
  notify_email_html    = "${local.simple_monitor_notify_email}"
  notify_slack_enabled = "${local.simple_monitor_notify_slack}"
  notify_slack_webhook = "${var.simple_monitor_slack_webhook}"

  description = "Simple-Monitor for ${local.fqdn} front web-servers[${local.monitoring_targets[count.index]} is responded not 2xx status]}]"
  tags        = ["production", "simple-monitor", "usacloud"]
  icon_id     = "${sakuracloud_icon.icon.id}"
}
