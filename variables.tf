
variable "zonal" {
  type        = bool
  description = "Enable if you want this to be a zonal cluster. If true, this will be set to zone `a` for the region specified."
}


variable "gke_version" {
  type        = string
  default     = "1.28.11-gke.1260000"
  description = "Static Channel GKE version to use. This applies only to the master/control plane and not the nodes. Please specify a matching version for the nodes in the node pool definition. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "region to deploy the cluster in"
}

variable "project_id" {
  type        = string
  description = "project id to deploy the cluster in"
}

variable "kubernetes_network_ranges" {
  type = map(string)
  default = {
    kubernetes_pods     = "10.65.0.0/16"
    kubernetes_services = "10.64.224.0/20"
    kubernetes_nodes    = "10.64.64.0/23"
  }
  description = "CIDR ranges to use for the cluster deployment."
}





variable "cluster_supported_node_pool_zones" {
  type    = list(string)
  default = ["a", "b", "c"]
}


# https://stackoverflow.com/questions/65431896/is-it-possible-to-create-a-zone-only-node-pool-in-a-regional-cluster-in-gke/65441255#65441255
variable "node_pools" {
  type = list(object({
    name              = string
    node_count        = number
    machine_type      = string
    disk_type         = string
    disk_size_gb      = number
    gke_version       = string
    spot              = bool
    preemptible       = bool
    kubernetes_labels = map(string)
    kubernetes_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
    node_pool_zones = list(string)
  }))
  default = [{
    disk_size_gb      = 20
    disk_type         = "pd-standard"
    gke_version       = "1.28.11-gke.1260000"
    node_count        = 1
    machine_type      = "e2-medium"
    name              = "default-pool"
    spot              = false
    preemptible       = false
    kubernetes_labels = {}
    kubernetes_taints = []
    node_pool_zones   = ["a"]
  }]
  description = <<-DESC
  node pool configurations:
    - name (string): Name of the node pool. MUST BE UNIQUE! Recommended to use YYYYMMDD in the name
    - node_count (number): number of nodes to create in the node pool.
    - machine_type (string): Machine type to use for the nodes. ref: https://gcpinstances.doit-intl.com/
    - disk_type (string): Disk type to use for the nodes. ref: https://cloud.google.com/compute/docs/disks
    - disk_size_gb (number): Disk size in GB for the nodes.
    - gke_version (string): GKE version to use for the nodes. ref: https://cloud.google.com/kubernetes-engine/docs/release-notes
    - spot (bool): Enable spot instances for the nodes. DO NOT ENABLE IN PROD!
  DESC
}

variable "network_peering_configurations" {
  description = <<EOF
  A list of network peering configurations. Each configuration is an object with the following attributes:
  - 'peer_network': The self-link of the peer network for the peering (e.g., 'projects/[PROJECT_ID]/global/networks/[NETWORK_NAME]').
  - 'peering_name': A unique name for the peering connection.
  - 'export_custom_routes': A boolean indicating whether custom routes will be exported from the network (default: false).
  - 'export_subnet_routes_with_public_ip': A boolean indicating whether subnet routes with public IP will be exported (default: false).
  - 'import_custom_routes': A boolean indicating whether custom routes will be imported from the peer network (default: false).
  
  This variable enables the dynamic creation and management of multiple network peerings.
  The default is an empty list, indicating no peerings will be established if not specified.

  Example:
    [
      {
        peer_network = "projects/example-project/global/networks/example-network-1"
        peering_name = "example-peering-1"
        export_custom_routes = false
        export_subnet_routes_with_public_ip = true
        import_custom_routes = false
      },
      {
        peer_network = "projects/example-project/global/networks/example-network-2"
        peering_name = "example-peering-2"
        export_custom_routes = true
        export_subnet_routes_with_public_ip = false
        import_custom_routes = true
      }
    ]
  EOF
  type = list(object({
    peer_network                        = string
    peering_name                        = string
    export_custom_routes                = bool
    export_subnet_routes_with_public_ip = bool
    import_custom_routes                = bool
  }))
  default = []
}
