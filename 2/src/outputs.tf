output "s3_bucket_url" {
  value = "https://${yandex_storage_bucket.glubuchik-bucket.bucket}.storage.yandexcloud.net/"
}

output "image_url" {
  value = "https://${yandex_storage_bucket.glubuchik-bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.glubuchik-image.key}"
}

output "network_balancer_ip" {
  value = yandex_lb_network_load_balancer.lamp-balancer.listener.*.external_address_spec[0].*.address
  description = "Адрес сетевого балансировщика"
}

# output "application_balancer_ip" {
#   value = yandex_vpc_address.alb-address.external_ipv4_address[0].address
# }

output "instance_group_ids" {
  value = yandex_compute_instance_group.group-vms.instances.*.instance_id
}