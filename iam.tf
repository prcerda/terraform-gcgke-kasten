# Service Account for K10 for GCP
resource "google_service_account" "k10-sa" {
  account_id   = "sa-k10-helm-${local.saString}"
  display_name = "sa-k10-helm-${local.saString}"
}

#Creating SA Key for K10
resource "google_service_account_key" "sakey" {
  service_account_id = google_service_account.k10-sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

#Assigning IAM Roles to K10 Service Account
resource "google_project_iam_member" "kasten-default" {
  project = var.project
  role    = "roles/compute.storageAdmin"
  member  = "serviceAccount:${google_service_account.k10-sa.email}"
}

resource "google_project_iam_member" "kasten-locprofile" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.k10-sa.email}"
}

# Service Account for GKE Cluster
#resource "google_service_account" "gke-sa" {
#  account_id   = "sa-gke-${local.saString}"
#  display_name = "sa-gke-${local.saString}"
#}

#Assigning IAM Roles to GKE Service Account
# The Google predefined role Kubernetes Engine Node Service Account 
# roles/container.nodeServiceAccount) contains the minimum permissions needed to run a GKE cluster.
#resource "google_project_iam_member" "gke-nodes" {
#  project = var.project
#  role    = "roles/container.nodeServiceAccount"
#  member  = "serviceAccount:${google_service_account.gke-sa.email}"
#}

#resource "google_project_iam_member" "gke-compute" {
#  project = var.project
#  role    = "roles/compute.admin"
#  member  = "serviceAccount:${google_service_account.gke-sa.email}"
#}

