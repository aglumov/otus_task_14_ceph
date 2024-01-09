resource "yandex_compute_instance" "mon_mgr" {
  count                     = 3
  name                      = "mon${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname                  = "mon${count.index}"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 16
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    #nat       = false
    #nat       =  count.index==0 ? true : false
    nat = count.index == 0
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = count.index != 0 ? "#cloud-config\nssh_authorized_keys:\n- ${tls_private_key.ceph-key.public_key_openssh}" : "#cloud-config\nhostname: mon${count.index}\nwrite_files:\n- path: /home/ubuntu/.ssh/id_rsa\n  defer: true\n  permissions: 0600\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph-key.private_key_openssh}")}\n- path: /home/ubuntu/.ssh/id_rsa.pub\n  defer: true\n  permissions: 0600\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph-key.public_key_openssh}")}"
  }
}

resource "yandex_compute_instance" "mds" {
  count                     = 1
  name                      = "mds${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname                  = "mds${count.index}"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 16
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nssh_authorized_keys:\n- ${tls_private_key.ceph-key.public_key_openssh}"
  }
}

resource "yandex_compute_instance" "osd" {
  count                     = var.osd_count
  name                      = "osd${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname                  = "osd${count.index}"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_image_id
      size     = 16
      type     = "network-ssd"
    }
  }

  dynamic "secondary_disk" {
    for_each = range(var.disks_per_osd)
    content {
      auto_delete = false
      disk_id     = yandex_compute_disk.ceph-disk[count.index * var.disks_per_osd + secondary_disk.value].id
      mode        = "READ_WRITE"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nssh_authorized_keys:\n- ${tls_private_key.ceph-key.public_key_openssh}"
  }
}

resource "yandex_compute_disk" "ceph-disk" {
  count = var.osd_count * var.disks_per_osd
  name  = "osd-${floor(count.index / var.disks_per_osd)}-ceph-disk-${count.index % var.disks_per_osd}"
  type  = "network-hdd"
  zone  = var.yc_zones[floor(count.index / var.disks_per_osd) % length(var.yc_zones)]
  size  = 10
}
