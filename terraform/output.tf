output "public_ip_address" {
  description = "Public address to connect to"
  value       = yandex_compute_instance.mon_mgr[0].network_interface[0].nat_ip_address
}
