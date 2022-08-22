variable "gcp_project_id" {
  type        = string
  description = "your GCP project ID"
}

# -------------- TFC setup --------------
resource "tfe_workspace" "gcp-login-demo" {
  name           = "gcp-login-demo"
  organization   = var.organization_name
  tag_names      = ["gcp", "demo", "jit"]
  agent_pool_id  = data.tfe_agent_pool.test.id
  execution_mode = "agent"
  description    = "A Workspace to test the JIT feature with GCP"
}

# Variable Set
resource "tfe_variable_set" "gcp" {
  name         = "GCP access"
  description  = "some useful description"
  organization = var.organization_name
}

resource "tfe_variable" "GCP_TFC_WORKLOAD_IDENTITY_AUDIENCE" {
  key             = "TFC_WORKLOAD_IDENTITY_AUDIENCE"
  value           = "gcp.workload.identity"
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.gcp.id
}
resource "tfe_variable" "TFC_GCP_WORKLOAD_POOL_ID" {
  key             = "TFC_GCP_WORKLOAD_POOL_ID"
  value           = google_iam_workload_identity_pool.tfc-pool.workload_identity_pool_id
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.gcp.id
}
resource "tfe_variable" "TFC_GCP_WORKLOAD_PROVIDER_ID" {
  key             = "TFC_GCP_WORKLOAD_PROVIDER_ID"
  value           = google_iam_workload_identity_pool_provider.tfc-provider.workload_identity_pool_provider_id
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.gcp.id
}
resource "tfe_variable" "TFC_GCP_SERVICE_ACCOUNT_EMAIL" {
  key             = "TFC_GCP_SERVICE_ACCOUNT_EMAIL"
  value           = google_service_account.tfc-service-account.email
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.gcp.id
}

data "google_project" "project" {
  project_id = var.gcp_project_id
}
resource "tfe_variable" "TFC_GCP_PROJECT_NUMBER" {
  key             = "TFC_GCP_PROJECT_NUMBER"
  value           = data.google_project.project.number
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.gcp.id
}

resource "tfe_workspace_variable_set" "gcp-login-demo" {
  variable_set_id = tfe_variable_set.gcp.id
  workspace_id    = tfe_workspace.gcp-login-demo.id
}


# Workspace Variables
resource "tfe_variable" "TFC_GCP_REGION" {
  key          = "TFC_GCP_REGION"
  value        = "global"
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.gcp-login-demo.id
}


resource "tfe_variable" "gcp_project_id" {
  key          = "project_id"
  value        = var.gcp_project_id
  category     = "terraform"
  sensitive    = false
  workspace_id = tfe_workspace.gcp-login-demo.id
}
# -------------- GCP setup --------------



variable "service_list" {
  description = "APIs required for the project"
  type        = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com"
  ]
}

resource "google_project_service" "services" {
  project                    = var.gcp_project_id
  disable_dependent_services = true
  count                      = length(var.service_list)
  service                    = var.service_list[count.index]
}

resource "google_iam_workload_identity_pool" "tfc-pool" {
  project                   = var.gcp_project_id
  provider                  = google-beta
  workload_identity_pool_id = "my-tfc-pool"

}

resource "google_iam_workload_identity_pool_provider" "tfc-provider" {
  project                            = var.gcp_project_id
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc-pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "my-tfc-provider-id"
  attribute_mapping = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }
  oidc {
    issuer_uri        = "https://app.terraform.io"
    allowed_audiences = ["gcp.workload.identity"]
  }
  attribute_condition = "assertion.sub.startsWith(\"organization:${var.organization_name}:workspace:${tfe_workspace.gcp-login-demo.name}\")"
}

resource "google_service_account" "tfc-service-account" {
  project      = var.gcp_project_id
  account_id   = "tfc-service-account"
  display_name = "Terraform Cloud Service Account"
}

resource "google_service_account_iam_member" "tfc-service-account-binding" {
  service_account_id = google_service_account.tfc-service-account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfc-pool.name}/attribute.terraform_run_phase/apply"
}

resource "google_project_iam_member" "project" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.tfc-service-account.email}"
}