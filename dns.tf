#DNS
data sakuracloud_dns "zone" {
  filter {
    names = [var.domain_name]
  }
}

#DNSレコード
resource sakuracloud_dns_record "releases" {
  dns_id = data.sakuracloud_dns.zone.id
  name   = var.subdomain_name
  type   = "CNAME"
  value  = "${sakuracloud_proxylb.releases.fqdn}."
  ttl    = 60
}

resource sakuracloud_dns_record "slack" {
  dns_id = data.sakuracloud_dns.zone.id
  name   = var.subdomain_slack_name
  type   = "CNAME"
  value  = "${sakuracloud_proxylb.slack.fqdn}."
  ttl    = 60
}

