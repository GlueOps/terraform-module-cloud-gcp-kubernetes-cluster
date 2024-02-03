
resource "google_service_account" "gke_node_pool" {
  account_id   = "gke-svc-acct"
  display_name = "Terraform-managed service account"

  depends_on = [
    google_project_service.activate_apis,
  ]
}


locals {
  node_locations = [for node_location in var.cluster_supported_node_pool_zones : format("%s-%s", var.region, node_location)]
}


resource "google_container_cluster" "captain" {
  name = "captain"

  location                    = var.zonal == true ? "${var.region}-a" : var.region
  min_master_version          = var.gke_version
  remove_default_node_pool    = true
  initial_node_count          = 1
  enable_intranode_visibility = true


  node_locations = local.node_locations

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

  monitoring_config {

    managed_prometheus {
      enabled = false
    }
    advanced_datapath_observability_config {
      enable_metrics = false
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = false
    }
    gcs_fuse_csi_driver_config {
      enabled = false

    }
    network_policy_config {
      disabled = true

    }

    http_load_balancing {
      disabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  resource_labels = {}

  lifecycle {
    ignore_changes = [
      node_config,
    ]
  }
}




resource "google_container_node_pool" "custom_pools" {
  for_each = { for np in var.node_pools : np.name => np }

  network_config {
    enable_private_nodes = false
    pod_range            = "kubernetes-pods"
  }

  version = each.value.gke_version

  name    = each.value.name
  cluster = google_container_cluster.captain.id

  initial_node_count = each.value.node_count
  node_locations     = [for node_location in each.value.node_pool_zones : format("%s-%s", var.region, node_location)]

  management {
    auto_upgrade = false
    auto_repair  = true
  }

  node_config {
    spot         = each.value.spot
    preemptible  = each.value.preemptible
    machine_type = each.value.machine_type
    disk_type    = each.value.disk_type
    disk_size_gb = each.value.disk_size_gb

    # If you still need the service account, add it as an input variable for the module
    service_account = google_service_account.gke_node_pool.email

    labels = each.value.kubernetes_labels
    dynamic "taint" {
      for_each = each.value.kubernetes_taints
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }

  }
}
