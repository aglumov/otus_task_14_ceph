resource "yandex_compute_instance" "lb" {
  count                     = 1
  name                      = "lb${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname = "lb${count.index}.otus.local"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      #image_id = "fd82sqrj4uk9j7vlki3q"   # ubuntu 22.04
      image_id = "fd839i1233e8krfrf92s"    # ubuntu 20.04
      size     = 8
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    nat       = true
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nhostname: lb${count.index}"
  }
}

resource "yandex_compute_instance" "mon_mgr" {
  count                     = 3
  name                      = "mon${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname = "mon${count.index}.otus.local"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      #image_id = "fd82sqrj4uk9j7vlki3q"   # ubuntu 22.04
      image_id = "fd839i1233e8krfrf92s"    # ubuntu 20.04
      size     = 8
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nhostname: mon${count.index}"
  }
}

resource "yandex_compute_instance" "mds" {
  count                     = 1
  name                      = "mds${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname = "mds${count.index}.otus.local"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      #image_id = "fd82sqrj4uk9j7vlki3q"   # ubuntu 22.04
      image_id = "fd839i1233e8krfrf92s"    # ubuntu 20.04
      size     = 8
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "#cloud-config\nhostname: mds${count.index}"
  }
}

resource "yandex_compute_instance" "osd" {
  count                     = 4
  name                      = "osd${count.index}"
  platform_id               = "standard-v3"
  zone                      = var.yc_zones[count.index % length(var.yc_zones)]
  allow_stopping_for_update = true
  hostname = "osd${count.index}.otus.local"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      #image_id = "fd82sqrj4uk9j7vlki3q"   # ubuntu 22.04
      image_id = "fd839i1233e8krfrf92s"    # ubuntu 20.04
      size     = 8
      type     = "network-ssd"
    }
  }

  secondary_disk {
    auto_delete = true
    disk_id     = yandex_compute_disk.osd-disk[count.index].id
    mode        = "READ_WRITE"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.yc_subnet[count.index % length(var.yc_zones)].id
    nat       = false
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_disk" "osd-disk" {
  count = 4
  name  = "osd${count.index}-secondary-disk"
  type  = "network-hdd"
  zone  = var.yc_zones[count.index % length(var.yc_zones)]
  size  = 10
}
