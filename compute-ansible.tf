# Instance Creation and Configuration

resource "oci_core_instance" "ADs_2" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")
  compartment_id      = var.compartment_ocid
  display_name        = "zlab-ansible"
  shape               = "VM.Standard.E2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet-zlab.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    private_ip       = "10.0.10.20"
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4cmgko5la45jui5cuju7byv6dgnfnjbxhwqxaei3q4zjwlliptuq"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(var.user-data-2)
  }

  timeouts {
    create = "60m"
  }
}

variable "user-data-2" {
  default = <<EOF
#!/bin/bash -x

echo "Creating SSH keys on Webserver.."
echo "0r4cl3" > /tmp/password.txt
cat /dev/zero | ssh-keygen -q -N ""

echo "Configuring Packages.."
yum install oracle-epel-release-el7.x86_64 -y
yum install ansible -y

echo "
[webservers]
10.0.10.10" > /etc/ansible/hosts

sshpass -f /tmp/password.txt ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@10.0.10.10

echo "Configuring Ansible Playbooks Repository Locally.."
yum install git -y
mkdir -p /playbooks
cd /playbooks
git clone https://github.com/jbcortezf/ansible-playbooks.git

EOF
}

output "zlab-ansible" {
  value = ["{oci_core_instance.zlab-ansible.public_ip}"]
}
