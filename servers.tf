# 公開鍵
resource sakuracloud_ssh_key "ssh_public_key" {
  name       = local.fqdn
  public_key = file("keys/admin_key.pub")
}

# パブリックアーカイブ(OS)のID参照用のデータソース定義
data sakuracloud_archive "k3os" {
  os_type = "k3os"
}

# ディスク定義
resource sakuracloud_disk "disks" {
  name              = local.fqdn
  size              = 40
  source_archive_id = data.sakuracloud_archive.k3os.id
  tags              = var.tags
  icon_id           = sakuracloud_icon.icon.id
}

# サーバー定義
resource sakuracloud_server "servers" {
  name   = local.fqdn
  disks  = [sakuracloud_disk.disks.id]
  core   = 1
  memory = 1
  tags   = var.tags
  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.filter.id
  }
  disk_edit_parameter {
    ssh_key_ids     = [sakuracloud_ssh_key.ssh_public_key.id]
    hostname        = var.subdomain_name
    password        = var.server_admin_password
    disable_pw_auth = true
  }

  icon_id = sakuracloud_icon.icon.id
}

