variable "private_connect_services" {
  description = "List of services to create with their respective details"
  type = list(object({
    name                   = string
    service_attachment_uri = string
  }))
  default = []
}

resource "google_compute_address" "private_service_connect_address" {
  for_each = { for svc in var.private_connect_services : svc.name => svc }

  name         = "psc-${each.value.name}"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.kubernetes.id
  region       = var.region
}

resource "google_compute_forwarding_rule" "private_service_connect_forwarding_rule" {
  for_each = { for svc in var.private_connect_services : svc.name => svc }

  name                  = "psc-${each.value.name}"
  load_balancing_scheme = "" # https://github.com/hashicorp/terraform-provider-google/issues/11225#issuecomment-1064930071
  region                = var.region
  ip_address            = google_compute_address.private_service_connect_address[each.key].id
  target                = each.value.service_attachment_uri
  network               = google_compute_network.vpc_network.id
}
