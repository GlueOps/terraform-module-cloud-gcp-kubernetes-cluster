
resource "google_compute_network" "vpc_network" {
  name                            = "captain"
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
  ip_cidr_range            = var.kubernetes_network_ranges["kubernetes_nodes"]
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "kubernetes-services"
    ip_cidr_range = var.kubernetes_network_ranges["kubernetes_services"]
  }

  secondary_ip_range {
    range_name    = "kubernetes-pods"
    ip_cidr_range = var.kubernetes_network_ranges["kubernetes_pods"]
  }

}
