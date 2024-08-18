<!-- BEGIN_TF_DOCS -->
# terraform-module-cloud-gcp-kubernetes-cluster

This terraform module is to help you quickly deploy a GKE cluster on Google Cloud Platform. This is part of the opionated GlueOps Platform.

### Example usage of module

```hcl
module "captain" {
  source = "git::https://github.com/GlueOps/terraform-module-cloud-gcp-kubernetes-cluster.git"
  kubernetes_network_ranges = {
    "kubernetes_pods" : "10.65.0.0/16",
    "kubernetes_services" : "10.64.224.0/20",
    "kubernetes_nodes" : "10.64.64.0/23"
  }
  private_connection_to_services = [
    {
      cidrs   = [{ name = "gcp-services-network-primary", cidr = "10.0.128.0/19" }, { name = "gcp-services-network-another", cidr = "10.1.128.0/19" }]
      service = "servicenetworking.googleapis.com"
    }
  ]
  private_connect_services = [
  #   {
  #   name = "db-mysql"
  #   service_attachment_uri = "projects/o12236157d3bd7c3ep-tp/regions/us-central1/serviceAttachments/a-7197c4ad7e38-psc-service-attachment-40adaaa378076d07"
  # },
  ]  
  project_id = "replace-with-actual-project-id"
  region     = "us-central1"
  zonal      = false
  cluster_supported_node_pool_zones = ["a","b","c"]
  node_pools = [
    {
      name         = "glueops-platform-node-pool-1"
      machine_type = "c2-standard-4"
      disk_type    = "pd-standard"
      disk_size_gb = 30
      auto_upgrade = false
      auto_repair  = true
      gke_version  = "1.28.11-gke.1172000"
      node_count   = 2
      spot         = false
      preemptible  = false
      node_pool_zones = ["a","b"]
      kubernetes_labels = {
        "glueops.dev/role" : "glueops-platform"
      }
      kubernetes_taints = [
        {
          key    = "glueops.dev/role"
          value  = "glueops-platform"
          effect = "NO_SCHEDULE"
        }
      ]
    },
    {
      name         = "glueops-node-pool-argocd-app-ctrl-1"
      machine_type = "c2-standard-4"
      disk_type    = "pd-standard"
      disk_size_gb = 30
      auto_upgrade = false
      auto_repair  = true
      gke_version  = "1.28.11-gke.1172000"
      node_count   = 2
      spot         = false
      preemptible  = false
      node_pool_zones = ["a","b"]
      kubernetes_labels = {
        "glueops.dev/role" : "glueops-platform-argocd-app-controller"
      }
      kubernetes_taints = [
        {
          key    = "glueops.dev/role"
          value  = "glueops-platform-argocd-app-controller"
          effect = "NO_SCHEDULE"
        }
      ]
    },
    {
      name         = "clusterwide-node-pool-1"
      machine_type = "c2-standard-4"
      disk_type    = "pd-standard"
      disk_size_gb = 30
      auto_upgrade = false
      auto_repair  = true
      gke_version  = "1.28.11-gke.1172000"
      node_count   = 2
      spot         = false
      preemptible  = false
      node_pool_zones = ["a","b"]
      kubernetes_labels = {}
      kubernetes_taints = []
    },
  ]
  gke_version = "1.28.11-gke.1172000"
  network_peering_configurations = [
#    {
#    peer_network                        = "projects/example-project/global/networks/example-network-2"
#    peering_name                        = "peering-networkA-to-networkB"
#    export_custom_routes                = false
#    export_subnet_routes_with_public_ip = true
#    import_custom_routes                = false
#    }
  ]
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.private_service_connect_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_forwarding_rule.private_service_connect_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_global_address.gcp_managed_services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_network_peering.peering](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_route.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_route) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_subnetwork.kubernetes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_container_cluster.captain](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [google_container_node_pool.custom_pools](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [google_project_iam_member.gke-project-roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.activate_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.gke_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_networking_connection.private_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_supported_node_pool_zones"></a> [cluster\_supported\_node\_pool\_zones](#input\_cluster\_supported\_node\_pool\_zones) | n/a | `list(string)` | <pre>[<br>  "a",<br>  "b",<br>  "c"<br>]</pre> | no |
| <a name="input_gke_version"></a> [gke\_version](#input\_gke\_version) | Static Channel GKE version to use. This applies only to the master/control plane and not the nodes. Please specify a matching version for the nodes in the node pool definition. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes | `string` | `"1.28.11-gke.1260000"` | no |
| <a name="input_kubernetes_network_ranges"></a> [kubernetes\_network\_ranges](#input\_kubernetes\_network\_ranges) | CIDR ranges to use for the cluster deployment. | `map(string)` | <pre>{<br>  "kubernetes_nodes": "10.64.64.0/23",<br>  "kubernetes_pods": "10.65.0.0/16",<br>  "kubernetes_services": "10.64.224.0/20"<br>}</pre> | no |
| <a name="input_network_peering_configurations"></a> [network\_peering\_configurations](#input\_network\_peering\_configurations) | A list of network peering configurations. Each configuration is an object with the following attributes:<br>  - 'peer\_network': The self-link of the peer network for the peering (e.g., 'projects/[PROJECT\_ID]/global/networks/[NETWORK\_NAME]').<br>  - 'peering\_name': A unique name for the peering connection.<br>  - 'export\_custom\_routes': A boolean indicating whether custom routes will be exported from the network (default: false).<br>  - 'export\_subnet\_routes\_with\_public\_ip': A boolean indicating whether subnet routes with public IP will be exported (default: false).<br>  - 'import\_custom\_routes': A boolean indicating whether custom routes will be imported from the peer network (default: false).<br><br>  This variable enables the dynamic creation and management of multiple network peerings.<br>  The default is an empty list, indicating no peerings will be established if not specified.<br><br>  Example:<br>    [<br>      {<br>        peer\_network = "projects/example-project/global/networks/example-network-1"<br>        peering\_name = "example-peering-1"<br>        export\_custom\_routes = false<br>        export\_subnet\_routes\_with\_public\_ip = true<br>        import\_custom\_routes = false<br>      },<br>      {<br>        peer\_network = "projects/example-project/global/networks/example-network-2"<br>        peering\_name = "example-peering-2"<br>        export\_custom\_routes = true<br>        export\_subnet\_routes\_with\_public\_ip = false<br>        import\_custom\_routes = true<br>      }<br>    ] | <pre>list(object({<br>    peer_network                        = string<br>    peering_name                        = string<br>    export_custom_routes                = bool<br>    export_subnet_routes_with_public_ip = bool<br>    import_custom_routes                = bool<br>  }))</pre> | `[]` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | node pool configurations:<br>  - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name<br>  - node\_count (number): number of nodes to create in the node pool.<br>  - machine\_type (string): Machine type to use for the nodes. ref: https://gcpinstances.doit-intl.com/<br>  - disk\_type (string): Disk type to use for the nodes. ref: https://cloud.google.com/compute/docs/disks<br>  - disk\_size\_gb (number): Disk size in GB for the nodes.<br>  - gke\_version (string): GKE version to use for the nodes. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes<br>  - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD! | <pre>list(object({<br>    name              = string<br>    node_count        = number<br>    machine_type      = string<br>    disk_type         = string<br>    disk_size_gb      = number<br>    gke_version       = string<br>    spot              = bool<br>    preemptible       = bool<br>    kubernetes_labels = map(string)<br>    kubernetes_taints = list(object({<br>      key    = string<br>      value  = string<br>      effect = string<br>    }))<br>    node_pool_zones = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "disk_size_gb": 20,<br>    "disk_type": "pd-standard",<br>    "gke_version": "1.28.11-gke.1260000",<br>    "kubernetes_labels": {},<br>    "kubernetes_taints": [],<br>    "machine_type": "e2-medium",<br>    "name": "default-pool",<br>    "node_count": 1,<br>    "node_pool_zones": [<br>      "a"<br>    ],<br>    "preemptible": false,<br>    "spot": false<br>  }<br>]</pre> | no |
| <a name="input_private_connect_services"></a> [private\_connect\_services](#input\_private\_connect\_services) | List of services to create with their respective details | <pre>list(object({<br>    name                   = string<br>    service_attachment_uri = string<br>  }))</pre> | `[]` | no |
| <a name="input_private_connection_to_services"></a> [private\_connection\_to\_services](#input\_private\_connection\_to\_services) | GCP private connection configurations. | <pre>list(object({<br>    cidrs : list(object({<br>      name : string,<br>      cidr : string<br>    }))<br>    service : string<br>  }))</pre> | <pre>[<br>  {<br>    "cidrs": [<br>      {<br>        "cidr": "10.0.128.0/19",<br>        "name": "gcp-services-network-primary"<br>      },<br>      {<br>        "cidr": "10.1.128.0/19",<br>        "name": "gcp-services-network-another"<br>      }<br>    ],<br>    "service": "servicenetworking.googleapis.com"<br>  }<br>]</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | project id to deploy the cluster in | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | region to deploy the cluster in | `string` | `"us-central1"` | no |
| <a name="input_zonal"></a> [zonal](#input\_zonal) | Enable if you want this to be a zonal cluster. If true, this will be set to zone `a` for the region specified. | `bool` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
