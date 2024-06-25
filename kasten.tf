## Kasten namespace
resource "kubernetes_namespace" "kastenio" {
  depends_on = [module.gke,helm_release.gc-volumesnapclass]
  metadata {
    name = "kasten-io"
  }
}

## Kasten Helm
resource "helm_release" "k10" {
  depends_on = [module.gke,helm_release.gc-volumesnapclass]  
  name = "k10"
  namespace = kubernetes_namespace.kastenio.metadata.0.name
  repository = "https://charts.kasten.io/"
  chart      = "k10"
  
  set {
    name  = "externalGateway.create"
    value = true
  }

  set {
    name  = "secrets.googleApiKey"
    value = google_service_account_key.sakey.private_key
  }

  set {
    name  = "auth.tokenAuth.enabled"
    value = true
  } 
}

##  Creating authentication Token
resource "kubernetes_token_request_v1" "k10token" {
  depends_on = [helm_release.k10]

  metadata {
    name = "k10-k10"
    namespace = kubernetes_namespace.kastenio.metadata.0.name
  }
  spec {
    expiration_seconds = var.tokenexpirehours*3600
  }
}

## Getting Kasten LB Address
data "kubernetes_service_v1" "gateway-ext" {
  depends_on = [helm_release.k10]
  metadata {
    name = "gateway-ext"
    namespace = "kasten-io"
  }
}

## Accepting EULA
resource "kubernetes_config_map" "eula" {
  depends_on = [helm_release.k10]
  metadata {
    name = "k10-eula-info"
    namespace = "kasten-io"
  }
  data = {
    accepted = "true"
    company  = "Veeam"
    email = var.owner
  }
}


## Kasten GCS Location Profile
resource "helm_release" "gcs-locprofile" {
  depends_on = [helm_release.k10]
  name = "${var.cluster_name}-gcs-locprofile"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "gcs-locprofile"  
  
  set {
    name  = "bucketname"
    value = google_storage_bucket.repository.name
  }

  set {
    name  = "projectid"
    value = var.project
  }

  set {
    name  = "gcekey"
    value = google_service_account_key.sakey.private_key
  }

  set {
    name  = "region"
    value = var.region
  }    
}


## Kasten K10 Config
resource "helm_release" "k10-config" {
  depends_on = [helm_release.k10]
  name = "${var.cluster_name}-k10-config"
  repository = "https://prcerda.github.io/Helm-Charts/"
  chart      = "k10-config"  
  
  set {
    name  = "bucketname"
    value = google_storage_bucket.repository.name
  }

  set {
    name  = "buckettype"
    value = "gcs"
  }
}


