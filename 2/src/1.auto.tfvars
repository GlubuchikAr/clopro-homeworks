vpc_subnet = {
    public  = {
        name = "public",
        cidr = ["192.168.10.0/24"]
        },
    private = {
        name = "private",
        cidr = ["192.168.20.0/24"]
    }
}

instance_resources = {
        lamp-group = {
            name            = "lamp-group",
            platform_id     = "standard-v1",
            cores           = 2, 
            memory          = 1, 
            core_fraction   = 5,
            disk_image      = "fd827b91d99psvq5fjit",
            disk_type       = "network-hdd",
            disk_size       = 10,
            nat             = true
        }
    }