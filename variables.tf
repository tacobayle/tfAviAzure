variable "azure" {
  default = {
    rg = {
      name = "rg-avi-nic"
      location = "West Europe"
    }
    vnet = {
      name = "vnet-avi"
      cidr = "172.16.0.0/19"
      subnets = [
        {
          name = "subnet-mgmt"
          cidr = "172.16.1.0/24"
        },
        {
          name = "subnet-app"
          cidr = "172.16.2.0/24"
        },
        {
          name = "subnet-vip"
          cidr = "172.16.3.0/24"
        }
      ]
    }
    vnetName = "vnet-avi"
    vnetCidr = "172.16.0.0/19"
    sg = {
      name = "sg-avi"
      rules = [
        {
          name = "ssh"
          dest_port = 22
          protocol = "tcp"
        },
        {
          name = "tcp_dns"
          dest_port = 53
          protocol = "tcp"
        },
        {
          name = "http"
          dest_port = 80
          protocol = "tcp"
        },
        {
          name = "https"
          dest_port = 443
          protocol = "tcp"
        },
        {
          name = "tcp_8443"
          dest_port = 8443
          protocol = "tcp"
        },
        {
          name = "udp_dns"
          dest_port = 53
          protocol = "udp"
        },
        {
          name = "udp_123"
          dest_port = 123
          protocol = "udp"
        }
      ]
    }
    avi = {
      service_engine_groups = [
        {
          name = "Default-Group"
          ha_mode = "HA_MODE_SHARED"
          min_scaleout_per_vs = 1
          buffer_se = 0
          realtime_se_metrics = {
            enabled = true
            duration = 0
          }
        },
        {
          name = "seGroupCpuAutoScale"
          ha_mode = "HA_MODE_SHARED"
          min_scaleout_per_vs = 1
          buffer_se = 1
          auto_rebalance = true
          auto_rebalance_interval = 30
          auto_rebalance_criteria = [
            "SE_AUTO_REBALANCE_CPU"
          ]
          realtime_se_metrics = {
            enabled = true
            duration = 0
          }
        },
        {
          name: "seGroupGslb"
          ha_mode = "HA_MODE_SHARED"
          min_scaleout_per_vs: 1
          buffer_se: 0
          instance_flavor = "Standard_D2s_v3"
          extra_shared_config_memory = 2000
          accelerated_networking = false
          realtime_se_metrics = {
            enabled: true
            duration: 0
          }
        }
      ]
      virtualservices = {
        http = [
          {
            name = "app1"
            pool_ref = "pool1"
            services: [
              {
                port = 80
                enable_ssl = "false"
              },
              {
                port = 443
                enable_ssl = "true"
              }
            ]
          },
          {
            name = "app2-scaleSet"
            pool_ref = "pool2"
            services: [
              {
                port = 443
                enable_ssl = "true"
              }
            ]
          }
        ],
        dns = [
          {
            name = "app3-dns"
            services: [
              {
                port = 53
              }
            ]
          },
          {
            name = "app4-gslb"
            services: [
              {
                port = 53
              }
            ]
            se_group_ref: "seGroupGslb"
          }
        ]
      }
    }
  }
}

variable "azure_client_id_ro" {}
variable "azure_client_secret_ro" {}
variable "azure_subscription_id" {}
variable "azure_tenant_id" {}

variable "ssh_key" {
  default = {
    private = "~/creds/ssh/cloudKey"
    public = "~/creds/ssh/cloudKey.pub"
  }
}

variable "backend" {
  type = map
  default = {
    type = "Standard_B1s"
    userdata = "userdata/backend.sh"
    hostname = "backend"
    count = "3"
    offer = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku = "20_04-lts-gen2"
    version = "latest"
    username = "ubuntu"
  }
}

variable "scaleset" {
  type = map
  default = {
    type = "Standard_B1s"
    userdata = "userdata/scaleset.sh"
    name = "scaleSet"
    hostname = "backend"
    count = "2"
    offer = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku = "20_04-lts-gen2"
    version = "latest"
    username = "ubuntu"
  }
}

variable "jump" {
  type = map
  default = {
    hostname = "jump"
    type = "Standard_D2s_v3"
    userdata = "userdata/jump.sh"
    offer = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku = "20_04-lts-gen2"
    version = "latest"
    username = "ubuntu"
    avisdkVersion = "21.1.1"
  }
}

variable "ansible" {
  type = map
  default = {
    version = "2.10.7"
    prefixGroup = "azure"
    aviPbAbsentUrl = "https://github.com/tacobayle/ansibleAviClear"
    aviPbAbsentTag = "v1.02"
    aviConfigureTag = "v1.09"
    aviConfigureUrl = "https://github.com/tacobayle/ansibleAviConfig"
  }
}

variable "controller" {
  default = {
    environment = "AZURE"
    dns =  ["8.8.8.8", "8.8.4.4"]
    ntp = ["95.81.173.155", "188.165.236.162"]
    hostname = "controller"
    type = "Standard_DS4_v2"
    offer = "avi-vantage-adc"
    publisher = "avi-networks"
    sku = "nsx-alb-controller-2101"
    version = "21.01.01"
    aviVersion = "21.1.1"
    cluster = false
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "false"
    tenant_access_to_provider_se = "true"
    tenant_vrf = "false"
    aviCredsJsonFile = "~/ansible/creds.json"
  }
}

variable "avi_password" {}
variable "avi_username" {}
variable "avi_old_password" {}