# 公開鍵
resource "sakuracloud_ssh_key" "ssh_public_key" {
  name        = "${local.fqdn}"
  public_key  = "${file("keys/admin_key.pub")}"
  description = "Public Key for ssh to ${local.fqdn}"
}

# パブリックアーカイブ(OS)のID参照用のデータソース定義
data sakuracloud_archive "rancheros" {
  os_type = "rancheros"
}

# ディスク定義
resource "sakuracloud_disk" "disks" {
  name              = "${local.fqdn}-disk${format("%02d",count.index+1)}"
  source_archive_id = "${data.sakuracloud_archive.rancheros.id}"
  ssh_key_ids       = ["${sakuracloud_ssh_key.ssh_public_key.id}"]
  hostname          = "front-web${format("%02d",count.index+1)}"
  password          = "${var.server_admin_password}"
  disable_pw_auth   = true

  note_ids = [
    "${sakuracloud_note.set_internal_network.*.id[count.index]}",
    "${sakuracloud_note.set_console.id}",
    "${sakuracloud_note.mount_nfs.id}",
  ]

  description = "Disks for ${local.fqdn} web-front"
  tags        = ["disk", "production", "usacloud"]
  icon_id     = "${sakuracloud_icon.icon.id}"

  count = "${var.front_web_server_count}"
}

# サーバー定義
resource "sakuracloud_server" "front" {
  name              = "${local.fqdn}-front-web${format("%02d",count.index+1)}"
  disks             = ["${sakuracloud_disk.disks.*.id[count.index]}"]
  core              = "${var.front_web_server_spec["core"]}"
  memory            = "${var.front_web_server_spec["memory"]}"
  packet_filter_ids = ["${sakuracloud_packet_filter.front_filter.id}"]
  additional_nics   = ["${sakuracloud_switch.internal.id}"]

  tags        = ["front", "production", "server", "usacloud"]
  description = "Servers for ${local.fqdn} web-front"

  icon_id = "${sakuracloud_icon.icon.id}"
  count   = "${var.front_web_server_count}"

  connection {
    host        = "${self.ipaddress}"
    user        = "rancher"
    private_key = "${file("keys/admin_key")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/${local.fqdn}",
      "sudo chown rancher. /opt/${local.fqdn}",
    ]
  }

  provisioner "file" {
    content     = "${data.template_file.webhook_dockerhub.rendered}"
    destination = "/home/rancher/webhook-dockerhub.yml"
  }

  provisioner "file" {
    content     = "${data.template_file.manual_deploy.rendered}"
    destination = "/home/rancher/manual_deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/rancher/webhook-dockerhub.yml /var/lib/rancher/conf/webhook-dockerhub.yml",
      "sudo ros os upgrade --force",
    ]
  }
}

resource "null_resource" "provisioning_manager_node" {
  triggers {
    server_ids = "${sakuracloud_server.front.*.id[0]}"
  }

  connection {
    host        = "${sakuracloud_server.front.*.ipaddress[0]}"
    user        = "rancher"
    private_key = "${file("keys/admin_key")}"
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.provisioning_manager_node.rendered}",
    ]
  }
}

resource "null_resource" "provisioning_worker_node" {
  depends_on = ["null_resource.provisioning_manager_node"]
  count      = "${var.front_web_server_count}"

  triggers {
    server_ids = "${join("," , sakuracloud_server.front.*.id)}"
  }

  connection {
    host        = "${sakuracloud_server.front.*.ipaddress[count.index]}"
    user        = "rancher"
    private_key = "${file("keys/admin_key")}"
  }

  provisioner "remote-exec" {
    inline = [
      "${count.index == 0 ? "exit" : data.template_file.provisioning_worker_node.*.rendered[count.index]}",
    ]
  }
}

resource "null_resource" "provisioning_docker_stack" {
  depends_on = ["null_resource.provisioning_worker_node"]

  connection {
    host        = "${sakuracloud_server.front.*.ipaddress[0]}"
    user        = "rancher"
    private_key = "${file("keys/admin_key")}"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /mnt/nfs/${local.fqdn}",
      "sudo chmod +x manual_deploy.sh",
      "./manual_deploy.sh",
    ]
  }
}

# eth1へのIPアドレス設定
data template_file "set_internal_network" {
  template = "${file("templates/internal_network.yml")}"
  count    = "${var.front_web_server_count}"

  vars {
    ip   = "${cidrhost(local.front_ip_range, var.front_private_ip_offset + count.index)}"
    mask = "${var.front_private_network_mask}"
  }
}

resource "sakuracloud_note" "set_internal_network" {
  name    = "${local.fqdn}-front-web-internal-network"
  class   = "yaml_cloud_config"
  content = "${data.template_file.set_internal_network.*.rendered[count.index]}"
  count   = "${var.front_web_server_count}"
}

# consoleの設定
data template_file "set_console" {
  template = "${file("templates/console.yml")}"
}

resource "sakuracloud_note" "set_console" {
  name    = "${local.fqdn}-front-console"
  class   = "yaml_cloud_config"
  content = "${data.template_file.set_console.rendered}"
}

# NFSのマウント
data template_file "mount_nfs" {
  template = "${file("templates/nfs.yml")}"

  vars {
    ip         = "${sakuracloud_nfs.storage.ipaddress}"
    mount_path = "/mnt/nfs/"
  }
}

resource "sakuracloud_note" "mount_nfs" {
  name    = "${local.fqdn}-front-mount-nfs"
  class   = "yaml_cloud_config"
  content = "${data.template_file.mount_nfs.rendered}"
}

# webhook(DockerHub)用サービス定義
data template_file "webhook_dockerhub" {
  template = "${file("templates/webhook_dockerhub.yml")}"

  vars {
    fqdn = "${local.fqdn}"
  }
}

# マニュアルデプロイ用スクリプト
data template_file "manual_deploy" {
  template = "${file("templates/manual_deploy.sh")}"

  vars {
    fqdn = "${local.fqdn}"
  }
}

# managerノード プロビジョニング
data template_file "provisioning_manager_node" {
  template = "${file("templates/provisioning_manager_node.sh")}"

  vars {
    ip                 = "${cidrhost(local.front_ip_range, var.front_private_ip_offset)}"
    user_name          = "${var.webhook_user}"
    password           = "${var.webhook_password}"
    fqdn               = "${local.fqdn}"
    build_docker_stack = "${file("templates/build_docker_stack.sh")}"
  }
}

# workerノード プロビジョニング
data template_file "provisioning_worker_node" {
  template = "${file("templates/provisioning_worker_node.sh")}"
  count    = "${var.front_web_server_count}"

  vars {
    ip   = "${cidrhost(local.front_ip_range, var.front_private_ip_offset + count.index)}"
    fqdn = "${local.fqdn}"
  }
}
