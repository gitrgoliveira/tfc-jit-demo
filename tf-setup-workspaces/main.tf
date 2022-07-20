
variable "tfe_agent_pool_name" {
  type        = string
  description = "Agent pool name to use"
}
variable "organization_name" {
  type        = string
  description = "name of the TFC organization"
}

data "tfe_agent_pool" "test" {
  name         = var.tfe_agent_pool_name
  organization = var.organization_name
}

