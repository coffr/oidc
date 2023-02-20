terraform {
  source = "../../../modules//audit"
}

include "root" {
  path = find_in_parent_folders()
}
