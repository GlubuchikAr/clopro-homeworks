variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "vpc_subnet" {
  type        = map(object({
    name = string,
    cidr = list(string)
    }))
  default     = {
    default = {
      name = "default",
      cidr = ["10.0.1.0/24"]
      }}
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "instance_resources" {
  type        = map(object({
    name          = string,
    platform_id   = string,
    cores         = number,
    memory        = number,
    core_fraction = number,
    disk_image    = string,
    disk_type     = string,
    disk_size     = number,
    nat           = bool
  }))
  default     = {
    default = {
      name          = "default",
      platform_id   = "standard-v1",
      cores         = 2, 
      memory        = 1, 
      core_fraction = 5,
      disk_image    = "fd80mrhj8fl2oe87o4e1",
      disk_type     = "network-hdd",
      disk_size     = 10,
      nat           = true
      }}
  description = "instance_resources"
}

