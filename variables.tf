
variable "zonal" {
  type        = bool
  description = "Enable if you want this to be a zonal cluster. If true, this will be set to zone a for the region specified."
}


variable "gke_version" {
  type        = string
  default = "1.24.10-gke.2300"
  description = "Static Channel GKE version to use. This applies only to the master/control plane and not the nodes. Please specify a matching version for the nodes in the node pool definition."
}

variable "region" {
  default     = "us-central1"
  description = "region to deploy the cluster in"
}

variable "project_id" {
  description = "project id to deploy the cluster in"
}

variable "network_ranges" {
  type = map(string)
  default = {
    kubernetes_pods     = "10.65.0.0/16"
    kubernetes_services = "10.64.224.0/20"
    kubernetes_nodes    = "10.64.64.0/23"
  }
  description = "CIDR ranges to use for the cluster deployment."
}

variable "node_pools" {
  type = list(object({
    name               = string
    initial_node_count = number
    machine_type       = string
    disk_type          = string
    disk_size_gb       = number
    gke_version        = string
    spot               = bool
  }))
  default = [ {
    disk_size_gb = 20
    disk_type = "pd-standard"
    gke_version = "1.24.10-gke.2300"
    initial_node_count = 1
    machine_type = "e2-medium"
    name = "default-pool"
    spot = true
  } ]
  description = "A list of objects containing node pool configurations."
}