# oracle-technical-assessment
Repository for Oracle Assessment

Hello Oracle!

Well, this is the repository for the Oracle Assessment.

It's using Terraform + OCI Cloud + Ansible.

We can find 5 files here:

env-vars = where you need to change accordly to your oci account

variables.tf = the terraform file where some of the vars are declared to be used by tf scripts

compute-webserver.tf = the terraform file for the webserver instance configuration

compute-ansible.tf = the terraform file for the ansible instance configuration

vcn.tf = the terraform file for the network configuration

The result of my deploy can be check at: http://130.61.74.252:8080/

Grafana Dashboard for Webserver Monitoring was deployed at: http://130.61.74.252:3000/

Note about Grafana
------------------

Grafana Dashboard with the plugin enabled needs to be enabled after installation. It'll needed to attach some API Key from some grafana account in order to run. After that, just put as home dashboard the preferred dashboard of your choice (The plugin provides 4). 

On the version available at the addresses above I just configured this (and this is the only thing in the entire deploy that I didn't automated because I need to study a little bit more to see if it can be also automated or not).

User and Password already sent to email, remains the same.

Note about Ansible Scripts
--------------------------

I tried to make it as simple and functional as possible.

Scripts are:

1) install-docker.yml          = just an example to install python36-docker package on webserver, ****but no need to run***
2) start-docker.yml            = starts the docker httpd container
3) stop-docker.yml             = stops the docker
4) containerchange-log.yml     = change the httpd log environment of the container to a local /wwwlog directory on host machine

Ansible Playbooks were placed on /playbooks/ansible-playbooks directory on ansible instance. Please note that, the ansible-playbook command should use -e 'ansible_python_interpreter=/usr/bin/python3'

Example:
     
     ansible-playbook stop-docker.yml -e 'ansible_python_interpreter=/usr/bin/python3'
   
Best Regards,

João Cortez.
