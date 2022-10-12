resource "local_file" "inventory" {
  filename = "../ansible/inventory"
  content  = <<EOF
[proxy]
${yandex_compute_instance.proxy.network_interface.0.nat_ip_address}

[dbs]
db01 ansible_ssh_host=${yandex_compute_instance.db[0].network_interface.0.ip_address}
db02 ansible_ssh_host=${yandex_compute_instance.db[1].network_interface.0.ip_address}

[wp]
${yandex_compute_instance.wordpress.network_interface.0.ip_address}

[gl]
${yandex_compute_instance.gitlab.network_interface.0.ip_address}

[run]
${yandex_compute_instance.runner.network_interface.0.ip_address}

[mon]
${yandex_compute_instance.monitoring.network_interface.0.ip_address}

[node_exporters]
${yandex_compute_instance.proxy.network_interface.0.ip_address}
${yandex_compute_instance.db[0].network_interface.0.ip_address}
${yandex_compute_instance.db[1].network_interface.0.ip_address}
${yandex_compute_instance.wordpress.network_interface.0.ip_address}
${yandex_compute_instance.gitlab.network_interface.0.ip_address}
${yandex_compute_instance.runner.network_interface.0.ip_address}
${yandex_compute_instance.monitoring.network_interface.0.ip_address}

[dbs:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p rokovi@${yandex_compute_instance.proxy.network_interface.0.nat_ip_address}"'

[wp:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p rokovi@${yandex_compute_instance.proxy.network_interface.0.nat_ip_address}"'

[gl:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p rokovi@${yandex_compute_instance.proxy.network_interface.0.nat_ip_address}"'

[run:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p rokovi@${yandex_compute_instance.proxy.network_interface.0.nat_ip_address}"'

[mon:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p rokovi@${yandex_compute_instance.proxy.network_interface.0.nat_ip_address}"'
EOF

  depends_on = [
    yandex_compute_instance.proxy
  ]

}

