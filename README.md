<!-- BEGIN_TF_DOCS -->
# terraform-module-cloud-gcp-kubernetes-cluster

Creates a cluster in gcp

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
| [google_container_node_pool.name](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.gke-project-roles](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/project_iam_member) | resource |
| [google_project_service.activate_apis](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/project_service) | resource |
| [google_service_account.gke_node_pool](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/resources/service_account) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/4.47.0/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_ranges"></a> [network\_ranges](#input\_network\_ranges) | CIDR ranges to use for the cluster deployment. | `map(string)` | <pre>{<br>  "kubernetes_pods": "10.65.0.0/16",<br>  "kubernetes_services": "10.64.224.0/20",<br>  "public_primary": "10.64.64.0/23"<br>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project id to deploy the cluster in | `any` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region to deploy the cluster in | `string` | `"us-central1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->