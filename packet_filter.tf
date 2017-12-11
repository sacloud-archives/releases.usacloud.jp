resource "sakuracloud_packet_filter" "front_filter" {
  name        = "${local.fqdn}-front-packet-filter"
  description = "PacketFilter for ${local.fqdn} web-front"

  expressions = {
    protocol    = "tcp"
    dest_port   = "22"
    description = "allow-external:SSH"
  }

  expressions = {
    protocol    = "tcp"
    dest_port   = "80"
    description = "allow-external:HTTP(for Let's Encrypt)"
  }

  expressions = {
    protocol    = "tcp"
    dest_port   = "443"
    description = "allow-external:HTTPS"
  }

  expressions = {
    protocol = "icmp"
  }

  expressions = {
    protocol = "fragment"
  }

  expressions = {
    protocol    = "udp"
    source_port = "123"
  }

  expressions = {
    protocol    = "tcp"
    dest_port   = "32768-61000"
    description = "allow-from-server"
  }

  expressions = {
    protocol    = "udp"
    dest_port   = "32768-61000"
    description = "allow-from-server"
  }

  expressions = {
    protocol    = "ip"
    allow       = false
    description = "Deny ALL"
  }
}
