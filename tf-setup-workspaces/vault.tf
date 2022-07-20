
variable "vault_address" {
  type = string
}

resource "tfe_workspace" "vault-login-demo" {
  name           = "vault-login-demo"
  organization   = var.organization_name
  tag_names      = ["vault", "demo", "jit"]
  agent_pool_id  = data.tfe_agent_pool.test.id
  execution_mode = "agent"
  description    = "A Workspace to test the JIT feature with Vault"
}

resource "tfe_workspace" "vault-login-demo2" {
  name           = "vault-login-demo2"
  organization   = var.organization_name
  tag_names      = ["vault", "demo", "jit"]
  agent_pool_id  = data.tfe_agent_pool.test.id
  execution_mode = "agent"
  description    = "A second workspace to test the JIT feature with Vault"
}

resource "tfe_variable_set" "vault" {
  name         = "Vault access"
  description  = "some useful description"
  organization = var.organization_name
}

resource "tfe_workspace_variable_set" "vault-login-demo" {
  variable_set_id = tfe_variable_set.vault.id
  workspace_id    = tfe_workspace.vault-login-demo.id
}

resource "tfe_workspace_variable_set" "vault-login-demo2" {
  variable_set_id = tfe_variable_set.vault.id
  workspace_id    = tfe_workspace.vault-login-demo2.id
}

resource "tfe_variable" "VAULT_ADDR" {
  key             = "VAULT_ADDR"
  value           = var.vault_address
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.vault.id
}
resource "tfe_variable" "TFC_VAULT_ADDRESS" {
  key             = "TFC_VAULT_ADDRESS"
  value           = var.vault_address
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.vault.id
}


resource "tfe_variable" "TFC_WORKLOAD_IDENTITY_AUDIENCE" {
  key             = "TFC_WORKLOAD_IDENTITY_AUDIENCE"
  value           = "vault.workload.identity"
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.vault.id
}

resource "tfe_variable" "TFC_VAULT_RUN_ROLE" {
  key          = "TFC_VAULT_RUN_ROLE"
  value        = "tfc-role"
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.vault-login-demo.id
}

resource "tfe_variable" "TFC_VAULT_RUN_ROLE2" {
  key          = "TFC_VAULT_RUN_ROLE"
  value        = "tfc-role2"
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.vault-login-demo2.id
}
