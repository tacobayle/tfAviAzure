# tfAviAzure

## Goals
Spin up a full Azure/Avi environment through Terraform.

## Prerequisites:
- Terraform installed in the orchestrator VM
- Create an application (Read-Only) in Azure Active directory to allow the jump VM to access Azure API
- Make sure the following environment variables are defined:
```
TF_VAR_avi_old_password=**********************************
TF_VAR_avi_password=**********************************
TF_VAR_avi_username=admin
```
- Make sure Azure credential/details are configured as environment variable (the client_id and secret ending by ro are the details for the application used by the jump VM):
```
ARM_CLIENT_ID=**********************************
ARM_TENANT_ID=**********************************
ARM_CLIENT_SECRET=**********************************
ARM_SUBSCRIPTION_ID=**********************************
TF_VAR_azure_client_secret_ro=**********************************
TF_VAR_azure_client_id_ro=**********************************
TF_VAR_azure_subscription_id=**********************************
TF_VAR_azure_tenant_id=**********************************
```
- Make sure you approved the Avi T&C
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
az vm image list --publisher avi-networks --all
...
  {
    "offer": "avi-vantage-adc",
    "publisher": "avi-networks",
    "sku": "nsx-alb-controller-2101",
    "urn": "avi-networks:avi-vantage-adc:nsx-alb-controller-2101:21.01.01",
    "version": "21.01.01"
  },
...
az vm image terms accept --urn avi-networks:avi-vantage-adc:nsx-alb-controller-2101:21.01.01
```
- SSH Key (public and private) paths defined in var.ssh_key.public and var.ssh_key.private



## versions:

### terraform
```
Terraform v1.1.4
on linux_amd64
+ provider registry.terraform.io/hashicorp/azurerm v2.95.0
+ provider registry.terraform.io/hashicorp/null v3.1.0
+ provider registry.terraform.io/hashicorp/template v2.2.0
```

### Avi version
```
Avi 21.1.1
```

### Azure Region:
```
West Europe
```

## Variables:
- All the variables are stored in variables.tf

## Use the terraform plan to:
- Create resource group, vnet, subnets, route tables, security group, nat GW
- Create VMs: Backend, jump, Avi Controller
- Create a scale set
- Call ansible to do the Avi configuration based on dynamic inventory:
  - user config 
  - system config
  - cloud config
  - SE group config
  - VS-VIP config
  - group config
  - VS config  

## Run terraform:
```
terraform apply -auto-approve
terraform destroy -auto-approve
```
