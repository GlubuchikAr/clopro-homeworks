locals {
  ssh_public_key = file("~/.ssh/aglubuchik.pub")
  
  instance_metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${local.ssh_public_key}"
    user-data  = <<EOF
#!/bin/bash
cd /var/www/html
echo '<html><head><title>Picture</title></head> <body><h1>For the glory of Deus Mechanicus</h1><img src="http://${yandex_storage_bucket.glubuchik-bucket.bucket}.storage.yandexcloud.net/${yandex_storage_object.glubuchik-image.key}"></body></html>' > index.html
systemctl restart apache2
EOF
  }

  current_timestamp = timestamp()
  formatted_date = formatdate("DD-MM-YYYY", local.current_timestamp)
  bucket_name = "glubuchik-${local.formatted_date}"
}
