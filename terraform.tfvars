# GCP Settings
project   = "google-project-name"
region    = "europe-west2"
az        = ["europe-west2-a"]

#labels

owner = "patricio_cerda"
activity = "demo"

# CIDR block for the subnet inside the VNET where the appliance will be deployed.
subnet_cidr_block_ipv4 = "10.50.0.0/16"

cluster_name = "k10"
gke_num_nodes = 3
machine_type = "e2-standard-2"