# Instance Creation and Configuration

resource "oci_core_instance" "ADs" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")
  compartment_id      = var.compartment_ocid
  display_name        = "webserver-hello-oracle"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet-webserver.id
    display_name     = "primaryvnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4cmgko5la45jui5cuju7byv6dgnfnjbxhwqxaei3q4zjwlliptuq"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(var.user-data)
  }

  timeouts {
    create = "60m"
  }
}

variable "user-data" {
  default = <<EOF
#!/bin/bash -x

echo "Initiating Instance Customization.."
touch ~opc/userdata.`date +%s`.start

echo "Installing Apache.."
yum install -y httpd

sed -i "s/Listen 80/Listen 8080/g" /etc/httpd/conf/httpd.conf
echo "<html><head><title>Hello Oracle</title></head><body><h1>Hello Oracle :-)</h1></body></html>" > /var/www/html/index.html

systemctl enable httpd.service
systemctl start httpd.service

firewall-offline-cmd --add-service=http
firewall-offline-cmd --add-port=8080/tcp

systemctl enable firewalld

systemctl start firewalld

touch ~opc/userdata.`date +%s`.finish
echo "Finishing apache configuration.."

systemctl restart firewalld

EOF
}

output "webserver-hello-oracle" {
  value = ["{oci_core_instance.webserver-hello-oracle.public_ip}"]
}
