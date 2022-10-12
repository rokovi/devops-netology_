output "external_ip_address_proxy" {
  value = yandex_compute_instance.proxy.network_interface.0.nat_ip_address
}

output "internal_ip_address_proxy" {
  value = yandex_compute_instance.proxy.network_interface.0.ip_address
}

output "internal_ip_address_db01" {
  value = yandex_compute_instance.db[0].network_interface.0.ip_address
}

output "internal_ip_address_db02" {
  value = yandex_compute_instance.db[1].network_interface.0.ip_address
}

output "internal_ip_address_wordpress" {
  value = yandex_compute_instance.wordpress.network_interface.0.ip_address
}

output "internal_ip_address_gitlab" {
  value = yandex_compute_instance.gitlab.network_interface.0.ip_address
}

output "internal_ip_address_runner" {
  value = yandex_compute_instance.runner.network_interface.0.ip_address
}

output "internal_ip_address_monitoring" {
  value = yandex_compute_instance.monitoring.network_interface.0.ip_address
}