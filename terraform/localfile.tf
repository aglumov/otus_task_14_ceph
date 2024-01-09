resource "local_file" "ansible_inventory" {
  filename        = "../ansible/inventory.ini"
  file_permission = 0644
  content = templatefile("./inventory.tftpl",
    {
      public_ip_address   = yandex_compute_instance.mon_mgr[0].network_interface[0].nat_ip_address
      mon_ip_address_list = yandex_compute_instance.mon_mgr[*].network_interface[0].ip_address
      mon_vm_names        = yandex_compute_instance.mon_mgr[*].name
      mds_ip_address_list = yandex_compute_instance.mds[*].network_interface[0].ip_address
      mds_vm_names        = yandex_compute_instance.mds[*].name
      osd_ip_address_list = yandex_compute_instance.osd[*].network_interface[0].ip_address
      osd_vm_names        = yandex_compute_instance.osd[*].name
    }
  )
}

resource "local_file" "ansible_config" {
  filename        = "../ansible/ansible.cfg"
  file_permission = 0644
  content = templatefile("./ansible.cfg.tftpl",
    {
      public_ip_address = yandex_compute_instance.mon_mgr[0].network_interface[0].nat_ip_address
    }
  )
}

resource "local_file" "ceph_spec" {
  filename        = "../ansible/ceph_spec.yaml"
  file_permission = 0644
  content = templatefile("ceph_spec.yaml.tftpl",
    {
      mon_ip_address_list = yandex_compute_instance.mon_mgr[*].network_interface[0].ip_address
      mon_vm_names        = yandex_compute_instance.mon_mgr[*].name
      mon_vm_zones        = yandex_compute_instance.mon_mgr[*].zone
      mds_ip_address_list = yandex_compute_instance.mds[*].network_interface[0].ip_address
      mds_vm_names        = yandex_compute_instance.mds[*].name
      mds_vm_zones        = yandex_compute_instance.mds[*].zone
      osd_ip_address_list = yandex_compute_instance.osd[*].network_interface[0].ip_address
      osd_vm_names        = yandex_compute_instance.osd[*].name
      osd_vm_zones        = yandex_compute_instance.osd[*].zone
    }
  )
}
