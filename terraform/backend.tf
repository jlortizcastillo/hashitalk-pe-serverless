# --- /terraform/backend.tf ---

terraform {
  backend "remote" {
    organization = "jloc-cloud"

    workspaces {
      name = "hashitalk-pe-serverless-dev"
    }
  }
}