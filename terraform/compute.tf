#resource "yandex_compute_instance" "lb" {
#  count                     = 1
#  name                      = "lb${count.index}"
#  platform_id               = "standard-v3"
#  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
#  allow_stopping_for_update = true
#  hostname                  = "lb${count.index}.otus.local"
#
#  resources {
#    cores         = 2
#    memory        = 2
#    core_fraction = 50
#  }
#
#  boot_disk {
#    initialize_params {
#      image_id = var.vm_image_id
#      size     = 8
#      type     = "network-ssd"
#    }
#  }
#
#  network_interface {
#    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
#    nat       = true
#  }
#
#  metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#    #user-data = "#cloud-config\nhostname: lb${count.index}\nwrite_files:\n- path: /home/ubuntu/.ssh/id_rsa\n  defer: true\n  permissions: 600\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: base64encode(tls_private_key.ceph-key.private_key_openssh)"
#    #user-data = "#cloud-config\nhostname: lb${count.index}\nwrite_files:\n- path: /home/ubuntu/.ssh/id_rsa\n  defer: true\n  permissions: 0600\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph-key.private_key_openssh}")}\n- path: /home/ubuntu/.ssh/id_rsa.pub\n  defer: true\n  permissions: 0600\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph-key.public_key_openssh}")}"
#  }
#}

resource "yandex_compute_instance" "mon_mgr" {
  count                     = 3
  name                      = "mon${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname                  = "mon${count.index}.otus.local"

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
    user-data = count.index != 0 ? "#cloud-config\nhostname: mon${count.index}\nssh_authorized_keys:\n- ${tls_private_key.ceph-key.public_key_openssh}" : "#cloud-config\nhostname: mon${count.index}\nwrite_files:\n- path: /home/ubuntu/.ssh/id_rsa\n  defer: true\n  permissions: 0600\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph-key.private_key_openssh}")}\n- path: /home/ubuntu/.ssh/id_rsa.pub\n  defer: true\n  permissions: 0600\n  owner: ubuntu:ubuntu\n  encoding: b64\n  content: ${base64encode("${tls_private_key.ceph-key.public_key_openssh}")}"
  }
}

resource "yandex_compute_instance" "mds" {
  count                     = 1
  name                      = "mds${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname                  = "mds${count.index}.otus.local"

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
    user-data = "#cloud-config\nhostname: mds${count.index}\nssh_authorized_keys:\n- ${tls_private_key.ceph-key.public_key_openssh}"
  }
}

resource "yandex_compute_instance" "osd" {
  count                     = var.osd_count
  name                      = "osd${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname                  = "osd${count.index}.otus.local"

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

  #  secondary_disk {
  #    auto_delete = true
  #    disk_id     = yandex_compute_disk.osd-disk[count.index].id
  #    mode        = "READ_WRITE"
  #  }

  dynamic "secondary_disk" {
    for_each = range(var.disks_per_osd)
    content {
      auto_delete = true
      disk_id     = yandex_compute_disk.osd-disk[count.index * var.disks_per_osd + secondary_disk.value].id
      mode        = "READ_WRITE"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nhostname: osd${count.index}\nssh_authorized_keys:\n- ${tls_private_key.ceph-key.public_key_openssh}"
  }
}

resource "yandex_compute_disk" "osd-disk" {
  count = var.osd_count * var.disks_per_osd
  name  = "osd-${count.index % var.osd_count}-${floor(count.index / var.osd_count)}-secondary-disk-${count.index}"
  type  = "network-hdd"
  zone  = var.yc_zones[floor(count.index / var.osd_count) % length(var.yc_zones)]
  size  = 10
}
