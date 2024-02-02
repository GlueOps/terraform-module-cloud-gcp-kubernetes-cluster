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
  network = google_compute_network.vpc_network.id
  service = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [for conn in local.flattened_cidrs : google_compute_global_address.gcp_managed_services["${conn.name}-${conn.service}"].name]
}


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
      cidrs   = [{ name = "primary", cidr = "10.0.128.0/19" }, { name = "another", cidr = "10.1.128.0/19" }]
      service = "servicenetworking.googleapis.com"
    }
  ]
  description = "GCP private connection configurations."
}
