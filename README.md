<!-- BEGIN_TF_DOCS -->
# terraform-module-cloud-gcp-kubernetes-cluster

This Terraform module deploys everything you need in GCP to get a kubernetes cluster up and running. This repo should be used in the context of deploying with the [admiral](https://github.com/glueops/admiral) repository.

## Prerequisites

### Project Setup

1. Create a **new** GCP Project with the following APIs enabled: [`cloudresourcemanager.googleapis.com`, `compute.googleapis.com`].  These APIs can be enabled in Cloud Shell using:

```bash
gcloud services enable cloudresourcemanager.googleapis.com compute.googleapis.com
```

2. Service Quota increase: `In-use IP addresses (default is 8)` has too low of a default value for deploying Kubernetes and quota should be increased to 64 to create headroom in available IPs.
Edit the quota for `In-use IP addresses` in the [quota page](https://console.cloud.google.com/iam-admin/quotas) or with the following `gcloud` command.

```bash
gcloud alpha services quota update \
    --service=compute.googleapis.com --consumer=projects/<your-project-name> \
    --metric=compute.googleapis.com/global_in_use_addresses \
    --unit=1/{project} --value=64
```
\_Note: If the increase isn't immediate or you receive an error, contact GCP support/account management\_

![Screenshot of Quota Increase](https://user-images.githubusercontent.com/6570292/210277244-f3a75d06-763f-4bdc-805e-4f8bd3c77ad5.png)

### Service Account

1. [Create a service account](https://console.cloud.google.com/iam-admin/serviceaccounts/create) and [download the json key file](https://console.cloud.google.com/iam-admin/serviceaccounts/details/101612329871957262389/keys), save the file as `creds.json`

2. Set env variable while in the directory with the `creds.json`:

    ```bash

    export GOOGLE_CREDENTIALS=$(pwd)/creds.json
    ```

3. In the project, [grant the service account the `Owner` role](https://console.cloud.google.com/iam-admin/iam) by selecting `GRANT ACCESS` at the top of the screen and filling out the principal (your service account role) and the `Owner` role.

## Terraform Deployment

### Configuration

Create a `captain_configuration.tfvars` configuration file to deploy Kubernetes.  
A reasonable xample configuration for this module, be sure to update `project_id`, required, and `region`, if desired:

```hcl
kubernetes_cluster_configurations = {
  network_ranges = {
    "kubernetes_pods" : "10.65.0.0/16",
    "kubernetes_services" : "10.64.224.0/20",
    "kubernetes_nodes" : "10.64.64.0/23"
  }
  project_id = "glueops-demo-1"
  region     = "us-central1"
}
```

### Deployment
To deploy Kubernetes, run the following commands from the root directory of the repository you've created for your deployment:

```bash
terraform -chdir=admiral/kubernetes-cluster/gcp init
terraform -chdir=admiral/kubernetes-cluster/gcp apply -state=$(pwd)/terraform_states/kubernetes-cluster.terraform.tfstate -var-file=$(pwd)/captain_configuration.tfvars
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.47.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/compute_network) | resource |
| [google_compute_route.default](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/compute_route) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/compute_router) | resource |
| [google_compute_subnetwork.kubernetes](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/compute_subnetwork) | resource |
| [google_container_cluster.gke](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/container_cluster) | resource |
| [google_container_node_pool.primary](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.gke-project-roles](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/project_iam_member) | resource |
| [google_project_service.activate_apis](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/project_service) | resource |
| [google_service_account.gke_node_pool](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_initial_node_count"></a> [gke\_initial\_node\_count](#input\_gke\_initial\_node\_count) | Initial node count for Kubernetes. | `number` | `1` | no |
| <a name="input_network_ranges"></a> [network\_ranges](#input\_network\_ranges) | CIDR ranges to use for the cluster deployment. | `map(string)` | <pre>{<br>  "kubernetes_nodes": "10.64.64.0/23",<br>  "kubernetes_pods": "10.65.0.0/16",<br>  "kubernetes_services": "10.64.224.0/20"<br>}</pre> | no |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Configuration for GKE nodes. | `map(string)` | <pre>{<br>  "disk_size_gb": "20",<br>  "disk_type": "pd-ssd",<br>  "machine_type": "e2-medium"<br>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project id to deploy the cluster in | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region to deploy the cluster in | `string` | `"us-central1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->