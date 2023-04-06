terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }
  }
}

// bool variable with true as default
variable "zonal" {
  type        = bool
  description = "Enable if you want this to be a zonal cluster. If true, this will be set to zone a"
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

variable "gke_initial_node_pool_node_count" {
  type        = number
  default     = 1
  description = "Initial node count for the Kubernetes node pool. If zonal is true this is multipled by 3"
}

variable "node_config" {
  type = map(string)
  default = {
    machine_type = "c2-standard-4"
    disk_type    = "pd-ssd"
    disk_size_gb = "20"
  }
  description = "Configuration for GKE nodes."
}

provider "google" {
  project = var.project_id
  region  = var.region
}




resource "google_project_service" "activate_apis" {
  for_each = toset([
    "appengine.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
    "storage-api.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "networkmanagement.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudscheduler.googleapis.com",
    "redis.googleapis.com",
  ])

  service = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = false
}


resource "google_compute_network" "vpc_network" {
  name                            = "glueops-vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  routing_mode                    = "REGIONAL"
  depends_on = [
    google_project_service.activate_apis,
  ]
}


resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}



resource "google_compute_route" "default" {
  name             = "internet-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network.name
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"
  description      = "Default route to the Internet."
}

resource "google_compute_subnetwork" "kubernetes" {
  name                     = "public-subnet"
  description              = "Public Subnetwork"
  ip_cidr_range            = var.network_ranges["kubernetes_nodes"]
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "kubernetes-services"
    ip_cidr_range = var.network_ranges["kubernetes_services"]
  }

  secondary_ip_range {
    range_name    = "kubernetes-pods"
    ip_cidr_range = var.network_ranges["kubernetes_pods"]
  }


  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}



data "google_project" "project" {
}

resource "google_project_iam_member" "gke-project-roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ])
  member  = "serviceAccount:${google_service_account.gke_node_pool.email}"
  project = data.google_project.project.id #"projects/venkata-test-1-373323"
  role    = each.value
}

resource "google_service_account" "gke_node_pool" {
  account_id   = "gke-svc-acct"
  display_name = "Terraform-managed service account"

  depends_on = [
    google_project_service.activate_apis,
  ]
}

resource "google_container_cluster" "gke" {
  name = "gke"

  location                    = var.zonal == true ? "${var.region}-a" : var.region
  min_master_version          = "1.24.9-gke.3200"
  remove_default_node_pool    = true
  initial_node_count          = 1
  enable_intranode_visibility = true

  release_channel {
    channel = "UNSPECIFIED"
  }

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.kubernetes.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "kubernetes-pods"
    services_secondary_range_name = "kubernetes-services"
  }

  node_config {
    service_account = google_service_account.gke_node_pool.email
    tags            = ["gke"]
    spot            = false
  }


  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  resource_labels = {}

  lifecycle {
    ignore_changes = [
      node_config,
    ]
  }
}








# resource "google_container_node_pool" "primary" {
#   name = "primary-node-pool"

#   cluster = google_container_cluster.gke.id
#   network_config {
#     enable_private_nodes = false
#     pod_range            = "kubernetes-pods"
#   }

#   initial_node_count = var.zonal == true ? var.gke_initial_node_pool_node_count * 3 : var.gke_initial_node_pool_node_count

#   management {
#     auto_upgrade = false
#     auto_repair  = true
#   }

#   node_config {
#     spot            = var.zonal == true ? true : false
#     machine_type    = var.node_config.machine_type
#     disk_type       = var.node_config.disk_type
#     disk_size_gb    = var.node_config.disk_size_gb
#     service_account = google_service_account.gke_node_pool.email
#   }
# }


resource "google_container_node_pool" "custom_node_pool" {
  for_each = { for np in var.node_pools : np.name => np }

    network_config {
    enable_private_nodes = false
    pod_range            = "kubernetes-pods"
  }

  name    = each.value.name
  cluster = google_container_cluster.gke.id

  initial_node_count = var.zonal == true ? each.value.initial_node_count * 3 : each.value.initial_node_count

  management {
    auto_upgrade = each.value.auto_upgrade
    auto_repair  = each.value.auto_repair
  }

  node_config {
    spot         = var.zonal == true ? true : false
    machine_type = each.value.machine_type
    disk_type    = each.value.disk_type
    disk_size_gb = each.value.disk_size_gb

    # If you still need the service account, add it as an input variable for the module
    service_account = google_service_account.gke_node_pool.email
  }
}

variable "node_pools" {
  type = list(object({
    name               = string
    initial_node_count = number
    machine_type       = string
    disk_type          = string
    disk_size_gb       = number
    auto_upgrade       = bool
    auto_repair        = bool
  }))
  description = "A list of objects containing node pool configurations."
}

