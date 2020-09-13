# Instance Creation and Configuration

resource "oci_core_instance" "ADs" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")
  compartment_id      = var.compartment_ocid
  display_name        = "zlab-web-server"
  shape               = "VM.Standard.E2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet-zlab.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    private_ip       = "10.0.10.10"
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

echo "Adjusting sshd accesses.."
echo "root:0r4cl3" |chpasswd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

echo "Installing Docker.."
yum install -y docker

echo "Installing docker support for python36.."
yum install -y python36-pip
pip3 install docker-py

systemctl enable docker
systemctl start docker

echo "Installing Apache.."
mkdir -p /www
echo "<html><head><title>Hello Again Oracle</title></head><body><h1>Hello Again Oracle :-D</h1></body></html>" > /www/index.html
docker run -dit --name httpd -p 8080:80 -v /www/:/usr/local/apache2/htdocs/ httpd:2.4

echo "Installing Grafana.."
docker run -d -p 3000:3000 --name grafana -e "GF_INSTALL_PLUGINS=raintank-worldping-app" grafana/grafana:6.5.0

echo "Configuring firewall.."
firewall-offline-cmd --add-service=http
firewall-offline-cmd --add-port=8080/tcp
firewall-offline-cmd --add-port=3000/tcp
systemctl enable firewalld
systemctl start firewalld

echo "Finishing apache configuration.."

systemctl restart firewalld

echo "Installing grafana docker image as service to autostart on reboot..."

echo "[Unit]
Description=Grafana Docker Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start grafana
ExecStop=/usr/bin/docker stop grafana

[Install]
WantedBy=default.target" > /etc/systemd/system/grafana-docker.service

systemctl enable grafana-docker.service

echo "Installing httpd docker image as service to autostart on reboot..."

echo "[Unit]
Description=Httpd Docker Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start httpd
ExecStop=/usr/bin/docker stop httpd

[Install]
WantedBy=default.target" > /etc/systemd/system/httpd-docker.service

systemctl enable httpd-docker.service

touch ~opc/userdata.`date +%s`.finish

EOF
}

output "zlab-web-server" {
  value = ["{oci_core_instance.zlab-web-server.public_ip}"]
}
