resource "sakuracloud_proxylb" "releases" {
  name         = local.fqdn
  plan         = 100
  vip_failover = true
  health_check {
    protocol   = "tcp"
    delay_loop = 60
  }
  bind_port {
    proxy_mode        = "http"
    redirect_to_https = true
    port              = 80
  }
  bind_port {
    proxy_mode = "https"
    port       = 443
  }
  server {
    ip_address = sakuracloud_server.servers.ip_address
    port       = 80
  }
}

resource sakuracloud_proxylb_acme "releases" {
  proxylb_id       = sakuracloud_proxylb.releases.id
  accept_tos       = true
  common_name      = local.fqdn
  update_delay_sec = 120
}

resource "sakuracloud_proxylb" "slack" {
  name         = local.slack_fqdn
  plan         = 100
  vip_failover = true
  health_check {
    protocol   = "tcp"
    delay_loop = 60
  }
  bind_port {
    proxy_mode        = "http"
    redirect_to_https = true
    port              = 80
  }
  bind_port {
    proxy_mode = "https"
    port       = 443
  }
  server {
    ip_address = sakuracloud_server.servers.ip_address
    port       = 80
  }
}

resource sakuracloud_proxylb_acme "slack" {
  proxylb_id       = sakuracloud_proxylb.slack.id
  accept_tos       = true
  common_name      = local.slack_fqdn
  update_delay_sec = 120
}