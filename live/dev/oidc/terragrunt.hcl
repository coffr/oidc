terraform {
  source = "../../../modules//oidc"
}

include "root" {
  path = find_in_parent_folders()
}
