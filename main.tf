terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.62.1"
    }
  }
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

  disable_dependent_services = true
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
  min_master_version          = var.gke_version
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

resource "google_container_node_pool" "custom_node_pool" {
  for_each = { for np in var.node_pools : np.name => np }

  network_config {
    enable_private_nodes = false
    pod_range            = "kubernetes-pods"
  }

  version = each.value.gke_version

  name    = each.value.name
  cluster = google_container_cluster.gke.id

  initial_node_count = each.value.node_count

  management {
    auto_upgrade = false
    auto_repair  = true
  }

  node_config {
    spot         = each.value.spot
    machine_type = each.value.machine_type
    disk_type    = each.value.disk_type
    disk_size_gb = each.value.disk_size_gb

    # If you still need the service account, add it as an input variable for the module
    service_account = google_service_account.gke_node_pool.email
  }
}



