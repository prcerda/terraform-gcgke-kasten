output "k10_bucket_name" {
  description = "Kasten Bucket name"
  value = google_storage_bucket.repository.id
}

output "cluster_name" {
  value = module.gke.name
}

output "kubeconfig" {
  description = "Configure kubeconfig to access this cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.name} --region ${var.az[0]}"
}

output "k10token" {
  value = nonsensitive(kubernetes_token_request_v1.k10token.token)
}

output "k10url" {
  description = "Kasten K10 URL"
  value = "http://${data.kubernetes_service_v1.gateway-ext.status.0.load_balancer.0.ingress.0.ip}/k10/"
}

output "demoapp_url" {
  description = "Demo App URL"
  value = "http://${kubernetes_service_v1.stock-demo-svc.status.0.load_balancer.0.ingress.0.ip}"
}