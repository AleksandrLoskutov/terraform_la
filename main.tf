terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.76.0"
    }
  }
  required_version = "1.2.4"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-state-bucket-al"
    region     = "ru-central1-a"
    key        = "issue1/lemp.tfstate"
    access_key = "<INPUT>"
    secret_key = "<INPUT>"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

module "ya_instance_1" {
  source                = "./modules/instance"
  instance_family_image = "lemp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet1.id
  zone                  = yandex_vpc_subnet.subnet1.zone
}

module "ya_instance_2" {
  source                = "./modules/instance"
  instance_family_image = "lamp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet2.id
  zone                  = yandex_vpc_subnet.subnet2.zone
}

resource "yandex_lb_target_group" "target-group" {
  name = "target-group"
  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
    address   = module.ya_instance_1.internal_ip_address_vm
  }
  target {
    subnet_id = yandex_vpc_subnet.subnet2.id
    address   = module.ya_instance_2.internal_ip_address_vm
  }
}

resource "yandex_lb_network_load_balancer" "lb-balancer" {
  name = "load-balancer"

  listener {
    name = "listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.target-group.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 80
      }
    }
  }
}