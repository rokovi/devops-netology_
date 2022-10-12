resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 100"
  }

  depends_on = [
    local_file.inventory
  ]
}

resource "null_resource" "diplom" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -u rokovi -i ../ansible/inventory ../ansible/yc-diplom-done.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}

