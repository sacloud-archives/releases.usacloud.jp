resource sakuracloud_nfs "storage" {
  switch_id = "${sakuracloud_switch.internal.id}"
  plan      = "100"

  ipaddress   = "${var.nfs_private_ip}"
  nw_mask_len = "${var.front_private_network_mask}"

  name        = "${local.fqdn}-storage"
  description = "NFS for ${local.fqdn}"
  tags        = ["nfs", "production", "storage", "usacloud"]
  icon_id     = "${sakuracloud_icon.icon.id}"
}
