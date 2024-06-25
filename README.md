# Terraform K10GKE

***Status:** Work-in-progress. Please create issues or pull requests if you have ideas for improvement.*

# **Fully automated deploy of Google GKE Cluster with Kasten**
Example of using Terraform to automate the deploy of a Google GKE cluster, plus the installation and initial Kasten K10 configuration 


## Summary
This projects demostrates the process of deploying an Google GKE cluster, plus installing and configurig Kasten K10 using Terraform for fully automation of this process.  The resources to be created include:
* VPC Resources
* IAM Service Account with proper roles to install and use Kasten
* GKE Cluster
    - Volume Snapshot Class
* Google Cloud Storage Bucket
* Kasten
    - Token Authentication
    - Access via LoadBalancer
    - EULA agreement
    - Location Profile creation using Google Cloud Storage Bucket
    - Policy preset samples creation
* Demo App

**NOTE**: The Demo App has been build by [Timothy Dewin](https://github.com/tdewin/stock-demo/tree/main/kubernetes)

All the automation is done using Terraform and leveraging the Google Cloud, Kubernetes, and [Kasten K10](https://docs.kasten.io/latest/api/cli.html) APIs.

## Disclaimer
This project is an example of an deployment and meant to be used for testing and learning purposes only. Do not use in production. 


# Table of Contents

1. [Prerequisites](#Prerequisites)
2. [Installing GKE Cluster and Kasten](#Installing-GKE-Cluster-and-Kasten)
3. [Using the Google GKE cluster and Kasten](#Using-the-Google-GKE-cluster-and-Kasten)
4. [Destroying the GKE Cluster with Kasten](#Destroying-the-GKE-Cluster-with-Kasten)


## Prerequisites
To run this project you need to have some software installed and configured: 
1. [Terraform](https://developer.hashicorp.com/terraform/tutorials/Google Cloud-get-started/install-cli)
Ej. using brew for macOS

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

2. [Helm](https://helm.sh/docs/intro/install/)
Ej. using brew for macOS

```
brew install helm
```

3. [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
Ej. using brew for macOS

```
brew install kubectl
```

4. [Install GCloud CLI](https://cloud.google.com/sdk/docs/install)
Ej. for macOS

```
curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-480.0.0-darwin-x86_64.tar.gz" -o "gcloud.tar.gz"
tar -zxf gcloud.tar.gz
./google-cloud-sdk/install.sh
```

5. Configure GCloud CLI providing credentials with enough privileges to create resources in Google Cloud.
```
gcloud init
gcloud auth application-default login
gcloud components install gke-gcloud-auth-plugin
```

6. Download all terraform files and keep them locally, all in the same folder in your laptop.


## Installing GKE Cluster and Kasten
For Terraform to work, we need to provide certain information to be used as variables in the **terraform.tfvars** file.   


| Name                    | Type     | Default value       | Description                                                    |
| ----------------------- | -------- | ------------------- | -------------------------------------------------------------- |
| `region`                | String   | `europe-west2`      | Google Cloud Region where all resources will be created        |
| `az`                    | list(string)   | `["europe-west2-a"]`| Google Cloud Availability Zone where all resources will be created        |
| `project`               | String   | `gcp-project-name`  | Google Cloud Project name                            |
| `cluster_name`          | String   | `k10`               | Name of the cluster to be created.  All Google Cloud resources will use the same name  |
| `gke_num_nodes`         | Number   | `3`                 | Number of GKE Worker nodes to be created  |
| `machine_type`          | String   | `e2-standard-2`     | Machine type for GKE Worker nodes  |
| `subnet_cidr_block_ipv4`| String   | `10.50.0.0/16`      | CIDR for VPC Subnet to be created  |
| `owner`                 | String   | `patricio_cerda`    | Owner tag in Google Cloud            |
| `activity`              | String   | `demo`              | Activity tag in Google Cloud         |



### Building the GKE Cluster with Kasten
Once the variables are set, the only thing we need to do is to apply the Terraform files:
- By using a terminal, go to the folder containing all terraform files.
- Run the following commands
```
terraform init
terraform apply
```


## Using the Google GKE cluster and Kasten
Once Terraform is done building the infrastructure and installing Kasten, you will get the following information:

| Name                    | Value       | Description                                                    |
| ----------------------- | ----------- | -------------------------------------------------------------- |
| `cluster_name  `        | `gke-k10-1719243246`         | Name of the Google GKE cluster created, with a random number to prevent conflicts               |
| `demoapp_url`           | `http://34.142.124.14`              | URL to access the demo Stock app        |
| `k10url `               | `http://34.147.149.221/k10/`    | URL to access the Kasten K10 Dashboard  |
| `k10token`              | `eyJhbGciOiJSUzI1NiIsImtpZCI6IjVjODIyNTU`  | Token to be used for Kasten authentication |
| `k10_bucket_name`       | `gcs-k10-1719304682`              | Google Cloud S3 Bucket to be used as Location profile         |
| `kubeconfig`            | `gcloud container clusters get-credentials gke-k10-1719304682 --region europe-west2-a` | Command to configure the kubeconfig file and access the kubernetes cluster with kubectl  |


At this point, it's possible to run tests to backup and restore the demo App, creating policies and as an option it's also possible to use Kanister for consistent backups of the PostgreSQL database.


## Destroying the GKE Cluster with Kasten
Once you are done using the GKE cluster, you can destroy it alonside all other resources created with Terraform, by using the following command:
```
terraform destroy
```