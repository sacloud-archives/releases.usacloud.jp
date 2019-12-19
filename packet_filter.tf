resource sakuracloud_packet_filter "filter" {
  name = local.fqdn
}

resource sakuracloud_packet_filter_rules "rules" {
  packet_filter_id = sakuracloud_packet_filter.filter.id

  expression {
    protocol         = "tcp"
    destination_port = "22"
    description      = "allow-external:SSH"
  }

  dynamic "expression" {
    for_each = sakuracloud_proxylb.releases.proxy_networks
    content {
      protocol         = "tcp"
      source_network   = expression.value
      destination_port = "80"
      description      = "allow-external:HTTP"
    }
  }

  dynamic "expression" {
    for_each = sakuracloud_proxylb.slack.proxy_networks
    content {
      protocol         = "tcp"
      source_network   = expression.value
      destination_port = "80"
      description      = "allow-external:HTTP"
    }
  }

  expression {
    protocol = "icmp"
  }

  expression {
    protocol = "fragment"
  }

  expression {
    protocol    = "udp"
    source_port = "123"
  }

  expression {
    protocol         = "tcp"
    destination_port = "32768-60999"
    description      = "allow-from-server"
  }

  expression {
    protocol         = "udp"
    destination_port = "32768-60999"
    description      = "allow-from-server"
  }

  expression {
    protocol    = "ip"
    allow       = false
    description = "Deny ALL"
  }
}
