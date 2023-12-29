output "nginx_public_ip_address" {
  description = "Public address to connect to"
  value       = yandex_compute_instance.lb[*].network_interface[0].nat_ip_address
}

