#! /bin/sh

export VAULT_ADDR=http://192.168.68.118:8200
export VAULT_TOKEN=root

vault audit enable file file_path=./vault-audit-$(date "+%Y%m%d%H%M.%S").log.json


vault policy write tfc-policy - <<EOF
# Used to generate child tokens in vault
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/create" {
  capabilities = ["update"]
}
path "secret/*" {
  capabilities = ["read"]
}
EOF

vault policy write another-policy - <<EOF
# Used to generate child tokens in vault
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
path "auth/token/create" {
  capabilities = ["update"]
}
path "secret/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOF

vault auth enable -audit-non-hmac-response-keys=error jwt 
vault write auth/jwt/config \
    oidc_discovery_url="https://app.terraform.io" \
    bound_issuer="https://app.terraform.io"

vault write auth/jwt/role/tfc-role -<<EOF
{
  "role_type": "jwt",
  "user_claim": "terraform_organization_name",
  "token_policies": ["tfc-policy"],
  "bound_audiences": ["vault.workload.identity"],
  "bound_claims_type": "glob",
  "bound_claims": {
    "sub": "organization:hc-emea-sentinel-demo:workspace:vault-login-demo:run_phase:*"
  }
}
EOF

vault write auth/jwt/role/tfc-role2 -<<EOF
{
  "role_type": "jwt",
  "user_claim": "terraform_organization_name",
  "token_policies": ["another-policy"],
  "bound_audiences": ["vault.workload.identity"],
  "bound_claims_type": "glob",
  "bound_claims": {
    "sub": "organization:hc-emea-sentinel-demo:workspace:vault-login-demo2:run_phase:*"
  }
}
EOF