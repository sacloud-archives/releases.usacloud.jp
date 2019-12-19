resource sakuracloud_simple_monitor "node-health" {
  target = sakuracloud_server.servers.ip_address

  health_check {
    protocol = "ping"
  }

  delay_loop = 60

  notify_email_enabled = local.simple_monitor_notify_email
  notify_email_html    = local.simple_monitor_notify_email
  notify_slack_enabled = local.simple_monitor_notify_slack
  notify_slack_webhook = var.simple_monitor_slack_webhook

  tags    = var.tags
  icon_id = sakuracloud_icon.icon.id
}

resource sakuracloud_simple_monitor "site-health-releases" {
  target = local.fqdn

  health_check {
    protocol = "https"
    path     = "/status.html"
    status   = "200"
  }

  delay_loop = 300

  notify_email_enabled = local.simple_monitor_notify_email
  notify_email_html    = local.simple_monitor_notify_email
  notify_slack_enabled = local.simple_monitor_notify_slack
  notify_slack_webhook = var.simple_monitor_slack_webhook

  tags    = var.tags
  icon_id = sakuracloud_icon.icon.id
}

resource sakuracloud_simple_monitor "site-health-slack" {
  target = local.slack_fqdn

  health_check {
    protocol = "https"
    path     = "/"
    status   = "200"
  }

  delay_loop = 300

  notify_email_enabled = local.simple_monitor_notify_email
  notify_email_html    = local.simple_monitor_notify_email
  notify_slack_enabled = local.simple_monitor_notify_slack
  notify_slack_webhook = var.simple_monitor_slack_webhook

  tags    = var.tags
  icon_id = sakuracloud_icon.icon.id
}
