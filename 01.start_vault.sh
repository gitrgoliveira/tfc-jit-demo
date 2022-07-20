#! /bin/sh

export VAULT_LICENSE_PATH=/Users/ricardo/licenses/vault_v2lic.hclic
vault server -dev -dev-root-token-id="root" \
-log-level=debug \
-dev-listen-address=192.168.68.118:8200 2>&1 > ./vault-$(date "+%Y%m%d%H%M.%S").log &