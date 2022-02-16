#!/bin/bash
sudo apt-get update
sudo apt install -y python3-pip
sudo apt install -y jq
#pip3 install ansible==${ansibleVersion}
pip3 install ansible[azure]==${ansibleVersion}
pip3 install avisdk==${avisdkVersion}
pip3 install dnspython
pip3 install boto3
pip3 install botocore
sudo -u ${username} ansible-galaxy collection install azure.azcollection
sudo -u ${username} ansible-galaxy collection install vmware.alb
sudo -u ${username} pip3 install -r /home/${username}/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
sudo -u ${username} mkdir -p /home/${username}/.ssh
sudo mkdir -p /opt/ansible/inventory
sudo chmod -R 757 /opt/ansible/inventory
sudo tee /opt/ansible/inventory/inventory.azure_rm.yaml > /dev/null <<EOT
---
plugin: azure.azcollection.azure_rm
include_vm_resource_groups:
  - ${rg}
auth_source: auto

keyed_groups:
  - prefix: ${ansiblePrefixGroup}
    key: tags
EOT
#sudo chmod -R 755 /opt/ansible
sudo mkdir -p /etc/ansible
sudo tee /etc/ansible/ansible.cfg > /dev/null <<EOT
[defaults]
inventory      = /opt/ansible/inventory/inventory.azure_rm.yaml
private_key_file = /home/${username}/.ssh/${basename(privateKey)}
host_key_checking = False
host_key_auto_add = True
EOT
mkdir -p /home/${username}/.azure
tee /home/${username}/.azure/credentials > /dev/null <<EOT
[default]
subscription_id=${azure_subscription_id}
client_id=${azure_client_id}
secret=${azure_client_secret}
tenant=${azure_tenant_id}
EOT
echo "cloud init done" | tee /tmp/cloudInitDone.log