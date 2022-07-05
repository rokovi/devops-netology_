terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

 backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-bucket-rokovi"
    region     = "ru-central1"
    key        = "folder1/test1.tfstate"
#    access_key = "${var.access_key}"
#    secret_key = "${var.secret_key}"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}
