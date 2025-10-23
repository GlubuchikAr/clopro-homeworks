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
        nat-instance = {
            name            = "nat-instance",
            platform_id     = "standard-v1",
            cores           = 2, 
            memory          = 1, 
            core_fraction   = 5,
            disk_image      = "fd80mrhj8fl2oe87o4e1",
            disk_type       = "network-hdd",
            disk_size       = 10,
            nat             = true
        },
        public-vm = {
            name            = "public-vm",
            platform_id     = "standard-v1",
            cores           = 2, 
            memory          = 1, 
            core_fraction   = 5,
            disk_image      = "ubuntu-2004-lts",
            disk_type       = "network-hdd",
            disk_size       = 10,
            nat             = true
        },
        private-vm = {
            name            = "private-vm",
            platform_id     = "standard-v1",
            cores           = 2, 
            memory          = 1, 
            core_fraction   = 5,
            disk_image      = "ubuntu-2004-lts",
            disk_type       = "network-hdd",
            disk_size       = 10,
            nat             = false
        }
    }