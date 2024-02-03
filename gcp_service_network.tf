locals {
  flattened_cidrs = flatten([
    for service in var.private_connection_to_services : [
      for cidr in service.cidrs : {
        name    = cidr.name
        cidr    = cidr.cidr
        service = service.service
      }
    ]
  ])

  service_to_cidrs = {
    for service in var.private_connection_to_services :
    service.service => [for conn in local.flattened_cidrs : conn.name if conn.service == service.service]
  }
}

resource "google_compute_global_address" "gcp_managed_services" {
  for_each = { for conn in local.flattened_cidrs : "${conn.name}-${conn.service}" => conn }

  name          = each.value.name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = split("/", each.value.cidr)[0]
  prefix_length = split("/", each.value.cidr)[1]
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_connection" {
  for_each = local.service_to_cidrs

  network                 = google_compute_network.vpc_network.id
  service                 = each.key
  reserved_peering_ranges = [for name in each.value : google_compute_global_address.gcp_managed_services["${name}-${each.key}"].name]
}

variable "private_connection_to_services" {
  type = list(object({
    cidrs : list(object({
      name : string,
      cidr : string
    }))
    service : string
  }))
  default = [
    {
      cidrs   = [{ name = "gcp-services-network-primary", cidr = "10.0.128.0/19" }, { name = "gcp-services-network-another", cidr = "10.1.128.0/19" }]
      service = "servicenetworking.googleapis.com"
    }
  ]
  description = "GCP private connection configurations."
}
