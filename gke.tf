resource "time_static" "epoch" {}
locals {
  saString = "${time_static.epoch.unix}"
}

## Network components
module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 7.5"

  project_id   = var.project
  network_name = "vpc-${var.cluster_name}-${local.saString}"

  subnets = [
    {
      subnet_name   = "subnet-${var.cluster_name}"
      subnet_ip     = var.subnet_cidr_block_ipv4
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    ("subnet-${var.cluster_name}") = [
      {
        range_name    = "ip-range-pods-${local.saString}"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "ip-range-svc-${local.saString}"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}


#Storage Account in GCS
resource "google_storage_bucket" "repository" {
  name          = "gcs-${var.cluster_name}-${local.saString}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = true
  uniform_bucket_level_access = true
  public_access_prevention = "enforced"
  labels = {
    owner = var.owner
    activity = var.activity
  }
}

# GKE cluster
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 31.0"
  project_id                        = var.project
  name                              = "gke-${var.cluster_name}-${local.saString}"
  regional                          = false
  region                            = var.region
  zones                             = var.az
  network                           = module.gcp-network.network_name
  subnetwork                        = module.gcp-network.subnets_names[0]
  ip_range_pods                     = "ip-range-pods-${local.saString}"
  ip_range_services                 = "ip-range-svc-${local.saString}"
  create_service_account            = true
  service_account_name              = "sa-${var.cluster_name}-${local.saString}"
  deletion_protection               = false
  remove_default_node_pool          = true
  disable_legacy_metadata_endpoints = true
  http_load_balancing               = true
  network_policy                    = false
  horizontal_pod_autoscaling        = true
  filestore_csi_driver              = true
  dns_cache                         = false  
  kubernetes_version                = "1.29"
  cluster_resource_labels = {
    owner = var.owner
    activity = var.activity
  }  

  node_pools = [
    {
      name                        = "pool-01-${var.cluster_name}"
      machine_type                = var.machine_type
      node_locations              = var.az[0]
      autoscaling                 = true
      initial_node_count          = var.gke_num_nodes
      disk_type                   = "pd-standard"
      auto_upgrade                = true
      auto_repair                 = true
      preemptible                 = false

    },
  ]

  node_pools_labels = {
    all = {
      owner = var.owner
      activity = var.activity
    }
  }  
}


data "google_client_config" "provider" {}

data "google_container_cluster" "gke_cluster" {
  name     = module.gke.name
  location = var.az[0]
}

## GCE Disk VolumeSnapshotClass
resource "helm_release" "gc-volumesnapclass" {
  depends_on = [module.gke]
  name = "gc-volumesnapclass"
  create_namespace = true
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "gc-volumesnapclass"  
}