resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.vpc_subnet.public.name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vpc_subnet.public.cidr
}

resource "yandex_compute_instance" "nat-instance" {
  name        = var.instance_resources.nat-instance.name
  platform_id = var.instance_resources.nat-instance.platform_id

  resources {
    cores         = var.instance_resources.nat-instance.cores
    memory        = var.instance_resources.nat-instance.memory
    core_fraction = var.instance_resources.nat-instance.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.instance_resources.nat-instance.disk_image
      type     = var.instance_resources.nat-instance.disk_type
      size     = var.instance_resources.nat-instance.disk_size
    }
  }

  network_interface {
    subnet_id   = yandex_vpc_subnet.public.id
    ip_address  = cidrhost(yandex_vpc_subnet.public.v4_cidr_blocks[0], 254)
    nat         = var.instance_resources.nat-instance.nat
  }

  metadata = local.instance_metadata

}

data "yandex_compute_image" "image-public-vm" {
  family = var.instance_resources.public-vm.disk_image
}

resource "yandex_compute_instance" "public-vm" {
  name        = var.instance_resources.public-vm.name
  platform_id = var.instance_resources.public-vm.platform_id

  resources {
    cores         = var.instance_resources.public-vm.cores
    memory        = var.instance_resources.public-vm.memory
    core_fraction = var.instance_resources.public-vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image-public-vm.image_id
      type     = var.instance_resources.public-vm.disk_type
      size     = var.instance_resources.public-vm.disk_size
    }
  }
  
  network_interface {
    subnet_id   = yandex_vpc_subnet.public.id
    nat         = var.instance_resources.public-vm.nat
  }

  metadata = local.instance_metadata

}

resource "yandex_vpc_subnet" "private" {
  name           = var.vpc_subnet.private.name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vpc_subnet.private.cidr
  route_table_id = yandex_vpc_route_table.private-route.id
}

resource "yandex_vpc_route_table" "private-route" {
  name       = "private-route"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address 
  }
}

data "yandex_compute_image" "image-private-vm" {
  family = var.instance_resources.private-vm.disk_image
}

resource "yandex_compute_instance" "private-vm" {
  name        = var.instance_resources.private-vm.name
  platform_id = var.instance_resources.private-vm.platform_id

  resources {
    cores         = var.instance_resources.private-vm.cores
    memory        = var.instance_resources.private-vm.memory
    core_fraction = var.instance_resources.private-vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image-private-vm.image_id
      type     = var.instance_resources.private-vm.disk_type
      size     = var.instance_resources.private-vm.disk_size
    }
  }
  
  network_interface {
    subnet_id   = yandex_vpc_subnet.private.id
    nat         = var.instance_resources.private-vm.nat
  }

  metadata = local.instance_metadata

}