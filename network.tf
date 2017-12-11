#Switch
resource sakuracloud_switch "internal" {
  name        = "${local.fqdn}-internal"
  description = "Switch for ${local.fqdn} internal network"
  tags        = ["internal", "production", "switch", "usacloud"]
  icon_id     = "${sakuracloud_icon.icon.id}"
}

#GSLB
resource sakuracloud_gslb "gslb" {
  name = "${local.fqdn}"

  health_check = {
    protocol   = "ping"
    delay_loop = 10
  }

  description = "GSLB for ${local.fqdn}"
  tags        = ["gslb", "production", "usacloud"]
  icon_id     = "${sakuracloud_icon.icon.id}"
}

#GSLB配下のサーバ
resource sakuracloud_gslb_server "gslb_servers" {
  gslb_id   = "${sakuracloud_gslb.gslb.id}"
  ipaddress = "${sakuracloud_server.front.*.ipaddress[count.index]}"
  count     = "${var.front_web_server_count}"
}

#DNS
data sakuracloud_dns "zone" {
  filter = {
    name   = "Name"
    values = ["${var.domain_name}"]
  }
}

#DNSレコード
resource sakuracloud_dns_record "records" {
  dns_id = "${data.sakuracloud_dns.zone.id}"
  name   = "${var.subdomain_name}"
  type   = "CNAME"
  value  = "${sakuracloud_gslb.gslb.fqdn}."
  ttl    = 60
}
