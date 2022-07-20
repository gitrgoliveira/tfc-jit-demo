terraform {
}


provider "vault" {
}

resource "vault_kv_secret_v2" "a_secret" {
  mount = "secret"
  name = "kv/a"
  data_json = jsonencode(
  {
    zip = "zap",
    foo = "bar"
  }
  ) 
  
}