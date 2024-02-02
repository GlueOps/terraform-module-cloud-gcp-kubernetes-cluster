
resource "google_compute_network_peering" "peering" {
  for_each = { for peering in var.network_peering_configurations : peering.peering_name => peering }

  name                                = each.value.peering_name
  network                             = google_compute_network.vpc_network.self_link
  peer_network                        = each.value.peer_network
  export_custom_routes                = each.value.export_custom_routes
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  import_custom_routes                = each.value.import_custom_routes
}
