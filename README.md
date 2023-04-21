<!-- BEGIN_TF_DOCS -->
# terraform-module-cloud-gcp-kubernetes-cluster

This terraform module is to help you quickly deploy a GKE cluster on Google Cloud Platform. This is part of the opionated GlueOps Platform. If you came here directly then you should probably visit https://github.com/glueops/admiral as that is the start point.

## Prerequisites to use this Terraform module

- GCP Project
- Service account with environment variable set
- Service Quotas (Depending on Cluster Size)

For more details see: https://github.com/GlueOps/terraform-module-cloud-gcp-kubernetes-cluster/wiki/

### Example usage of module

```hcl
module "captain" {
  source = "git::https://github.com/GlueOps/terraform-module-cloud-gcp-kubernetes-cluster.git"
  network_ranges = {
    "kubernetes_pods" : "10.65.0.0/16",
    "kubernetes_services" : "10.64.224.0/20",
    "kubernetes_nodes" : "10.64.64.0/23"
  }
  project_id = "antoniostacos-nonprod"
  region     = "us-central1"
  zonal      = true

  node_pools = [
    {
      name               = "primary-node-pool"
      initial_node_count = 1
      machine_type       = "c2-standard-4"
      disk_type          = "pd-standard"
      disk_size_gb       = 30
      auto_upgrade       = false
      auto_repair        = true
      gke_version        = "1.25.8-gke.500"
      node_count         = 3
      spot               = true
    }
  ]
  gke_version = "1.25.8-gke.500"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.62.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.62.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/compute_network) | resource |
| [google_compute_route.default](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/compute_route) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/compute_router) | resource |
| [google_compute_subnetwork.kubernetes](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/compute_subnetwork) | resource |
| [google_container_cluster.gke](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/container_cluster) | resource |
| [google_container_node_pool.custom_node_pool](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.gke-project-roles](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/project_iam_member) | resource |
| [google_project_service.activate_apis](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/project_service) | resource |
| [google_service_account.gke_node_pool](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/4.62.1/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gke_version"></a> [gke\_version](#input\_gke\_version) | Static Channel GKE version to use. This applies only to the master/control plane and not the nodes. Please specify a matching version for the nodes in the node pool definition. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes | `string` | `"1.24.10-gke.2300"` | no |
| <a name="input_network_ranges"></a> [network\_ranges](#input\_network\_ranges) | CIDR ranges to use for the cluster deployment. | `map(string)` | <pre>{<br>  "kubernetes_nodes": "10.64.64.0/23",<br>  "kubernetes_pods": "10.65.0.0/16",<br>  "kubernetes_services": "10.64.224.0/20"<br>}</pre> | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | node pool configurations:<br>  - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name<br>  - node\_count (number): number of nodes to create in the node pool.<br>  - machine\_type (string): Machine type to use for the nodes. ref: https://gcpinstances.doit-intl.com/<br>  - disk\_type (string): Disk type to use for the nodes. ref: https://cloud.google.com/compute/docs/disks<br>  - disk\_size\_gb (number): Disk size in GB for the nodes.<br>  - gke\_version (string): GKE version to use for the nodes. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes<br>  - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD! | <pre>list(object({<br>    name         = string<br>    node_count   = number<br>    machine_type = string<br>    disk_type    = string<br>    disk_size_gb = number<br>    gke_version  = string<br>    spot         = bool<br>  }))</pre> | <pre>[<br>  {<br>    "disk_size_gb": 20,<br>    "disk_type": "pd-standard",<br>    "gke_version": "1.24.10-gke.2300",<br>    "machine_type": "e2-medium",<br>    "name": "default-pool",<br>    "node_count": 1,<br>    "spot": false<br>  }<br>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project id to deploy the cluster in | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region to deploy the cluster in | `string` | `"us-central1"` | no |
| <a name="input_zonal"></a> [zonal](#input\_zonal) | Enable if you want this to be a zonal cluster. If true, this will be set to zone `a` for the region specified. | `bool` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
