<!-- BEGIN_TF_DOCS -->
# terraform-module-cloud-gcp-kubernetes-cluster

This Terraform module deploys everything needed in GCP to get a kubernetes cluster up and running. This repo should be used in the context of deploying with the [admiral](https://github.com/glueops/admiral) repository.

## Prerequisites

### Project Setup

The project walkthrough relies upon `CloudShell`, but can also be completed in the console UI.

1. Create a **new** GCP Project and set configure cloud shell to new project context.
```bash
gcloud projects create <unique-project-id>
gcloud config set project <unique-project-id>
```

2. Enable Billing for the new Project

```bash
gcloud alpha billing projects link <unique-project-id> --billing-account=$(gcloud alpha billing accounts list --format=json | jq '.[]."name"'  | tr -d '"' | awk -F'/' '{ print $2}')
```

3. Enable the APIs required by the deployment: [`cloudresourcemanager.googleapis.com`, `compute.googleapis.com`].

```bash
gcloud services enable cloudresourcemanager.googleapis.com compute.googleapis.com
```

4. Service Quota increase: `In-use IP addresses (default is 8)` has too low of a default value for deploying a Kubernetes beyond 3 nodes and quota should be increased to 64 to create headroom in available IPs.
Edit the quota for `In-use IP addresses` in the [quota page](https://console.cloud.google.com/iam-admin/quotas).  Be sure to increase the quota for the region relevant to the new project.

![Screenshot of Quota Increase](https://user-images.githubusercontent.com/6570292/210277244-f3a75d06-763f-4bdc-805e-4f8bd3c77ad5.png)

### Service Account

1. [Create a service account](https://console.cloud.google.com/iam-admin/serviceaccounts/create).

```bash
gcloud iam service-accounts create <service-account-name> \
    --description="<service-account-description>" \
    --display-name="<service-account-display-name>"
```

2. [Grant the service account the `Owner` role](https://console.cloud.google.com/iam-admin/iam).

```bash
gcloud projects add-iam-policy-binding <unique-project-id> \
    --member="serviceAccount:<service-account-name>@<unique-project-id>.iam.gserviceaccount.com" \
    --role="roles/owner"
```

3. [Download the json key file](https://console.cloud.google.com/iam-admin/serviceaccounts/details/101612329871957262389/keys) and save the file as `creds.json` in the root directoy of the new directory created for this deployment.

```bash
gcloud iam service-accounts keys create creds.json \
    --iam-account=<service-account-name>@<unique-project-id>.iam.gserviceaccount.com
```

4. Set env variable while in the directory with the `creds.json`:

    ```bash

    export GOOGLE_CREDENTIALS=$(pwd)/creds.json
    ```

## Terraform Deployment

### Configuration

Create a `captain_configuration.tfvars` configuration file to deploy Kubernetes.  
A reasonable xample configuration for this module, be sure to update `project_id`, required, and `region`, if desired.  The region should be the same as the region for which the quota increase was requested above:

```hcl
kubernetes_cluster_configurations = {
  network_ranges = {
    "kubernetes_pods" : "10.65.0.0/16",
    "kubernetes_services" : "10.64.224.0/20",
    "kubernetes_nodes" : "10.64.64.0/23"
  }
  project_id = "<unique-project-id>"
  region     = "us-central1"
  zonal = true
}
```

### Deployment
To deploy Kubernetes, run the following commands from the root directory of created for this deployment:

```bash
terraform -chdir=admiral/kubernetes-cluster/gcp init
terraform -chdir=admiral/kubernetes-cluster/gcp apply -state=$(pwd)/terraform_states/kubernetes-cluster.terraform.tfstate -var-file=$(pwd)/captain_configuration.tfvars
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.53.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.53.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/compute_network) | resource |
| [google_compute_route.default](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/compute_route) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/compute_router) | resource |
| [google_compute_subnetwork.kubernetes](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/compute_subnetwork) | resource |
| [google_container_cluster.gke](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/container_cluster) | resource |
| [google_container_node_pool.primary](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.gke-project-roles](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/project_iam_member) | resource |
| [google_project_service.activate_apis](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/project_service) | resource |
| [google_service_account.gke_node_pool](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/4.53.1/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_initial_node_pool_node_count"></a> [gke\_initial\_node\_pool\_node\_count](#input\_gke\_initial\_node\_pool\_node\_count) | Initial node count for the Kubernetes node pool. If zonal is true this is multipled by 3 | `number` | `1` | no |
| <a name="input_network_ranges"></a> [network\_ranges](#input\_network\_ranges) | CIDR ranges to use for the cluster deployment. | `map(string)` | <pre>{<br>  "kubernetes_nodes": "10.64.64.0/23",<br>  "kubernetes_pods": "10.65.0.0/16",<br>  "kubernetes_services": "10.64.224.0/20"<br>}</pre> | no |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Configuration for GKE nodes. | `map(string)` | <pre>{<br>  "disk_size_gb": "20",<br>  "disk_type": "pd-ssd",<br>  "machine_type": "e2-medium"<br>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project id to deploy the cluster in | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region to deploy the cluster in | `string` | `"us-central1"` | no |
| <a name="input_zonal"></a> [zonal](#input\_zonal) | Enable if you want this to be a zonal cluster. If true, this will be set to zone a | `bool` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->