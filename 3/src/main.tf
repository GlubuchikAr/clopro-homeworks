# Создаем сервисный аккаунт для backet
resource "yandex_iam_service_account" "s3-sa" {
  folder_id     = var.folder_id
  name          = "service-account"
  description   = "Service account"
}

# Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "s3-sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3-sa.id}"
  depends_on = [yandex_iam_service_account.s3-sa]
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor-encrypter-decrypter" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.s3-sa.id}"
  depends_on = [yandex_iam_service_account.s3-sa]
}

# Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "s3-sa-keys" {
  service_account_id = yandex_iam_service_account.s3-sa.id
  description        = "Static access keys"
}

# Создание ключа KMS
resource "yandex_kms_symmetric_key" "bucket-key" {
  name              = "glubuchik-bucket-key"
  description       = "ключ для шифрования бакета"
  default_algorithm = "AES_256"
  rotation_period   = "24h"
}

# Создание бакета с использованием ключа
resource "yandex_storage_bucket" "glubuchik-bucket" {
  access_key = yandex_iam_service_account_static_access_key.s3-sa-keys.access_key
  secret_key = yandex_iam_service_account_static_access_key.s3-sa-keys.secret_key
  bucket     = local.bucket_name
  folder_id  = var.folder_id
  acl        = "public-read-write"

  # Включение шифрования на стороне сервера с KMS
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Загружаем картинку в S3 хранилище
resource "yandex_storage_object" "glubuchik-image" {
  access_key = yandex_iam_service_account_static_access_key.s3-sa-keys.access_key
  secret_key = yandex_iam_service_account_static_access_key.s3-sa-keys.secret_key
  bucket     = yandex_storage_bucket.glubuchik-bucket.bucket
  key        = var.image.name
  source     = var.image.path
  acl        = "public-read"

  depends_on = [yandex_storage_bucket.glubuchik-bucket]
}

# Создаем сеть и подсеть
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "public" {
  name           = var.vpc_subnet.public.name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vpc_subnet.public.cidr
}

# Создаем сервисный аккаунт для управления группой ВМ
resource "yandex_iam_service_account" "groupvm-sa" {
  name        = "groupvm-sa"
  description = "Сервисный аккаунт для управления группой ВМ."
}

resource "yandex_resourcemanager_folder_iam_member" "group-editor" {
  folder_id  = var.folder_id
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.groupvm-sa.id}"
  depends_on = [
    yandex_iam_service_account.groupvm-sa,
  ]
}

# Создаем группу ВМ
resource "yandex_compute_instance_group" "group-vms" {
  name                = var.instance_resources.lamp-group.name
  folder_id           = var.folder_id
  service_account_id  = "${yandex_iam_service_account.groupvm-sa.id}"
  deletion_protection = "false"
  depends_on          = [yandex_resourcemanager_folder_iam_member.group-editor]

  instance_template {
    platform_id = var.instance_resources.lamp-group.platform_id
    resources {
      memory = var.instance_resources.lamp-group.memory
      cores  = var.instance_resources.lamp-group.cores
      core_fraction = var.instance_resources.lamp-group.core_fraction
    }

  boot_disk {
    initialize_params {
      image_id = var.instance_resources.lamp-group.disk_image
      type     = var.instance_resources.lamp-group.disk_type
      size     = var.instance_resources.lamp-group.disk_size
    }
  }

  network_interface {
    network_id         = "${yandex_vpc_network.develop.id}"
    subnet_ids         = ["${yandex_vpc_subnet.public.id}"]
    nat = var.instance_resources.lamp-group.nat
  }

  scheduling_policy {
    preemptible = true
  }

    metadata = local.instance_metadata
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  health_check {
    interval = 30
    timeout  = 10
    tcp_options {
      port = 80
    }
  }

  load_balancer {
      target_group_name = "lamp-group"
  }
}

# Создание сетевого балансировщика
resource "yandex_lb_network_load_balancer" "lamp-balancer" {
  name = "lamp-network-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.group-vms.load_balancer[0].target_group_id

    healthcheck {
      name = "http-healthcheck"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}