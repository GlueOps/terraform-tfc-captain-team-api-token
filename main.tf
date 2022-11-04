terraform {
  required_providers {
    tfe = "0.38.0"
  }
}

variable "email" {
  type        = string
  description = "The email address of the organization for notifications"
}

variable "org_name" {
  type        = string
  description = "The name of the terraform cloud organization"
}


resource "tfe_organization" "org" {
  name  = var.org_name
  email = var.email
}

data "tfe_team" "owners" {
  name         = "owners"
  organization = tfe_organization.org.name
}

resource "tfe_team_token" "terraform_cloud_operator" {
  team_id          = data.tfe_team.owners.id
  force_regenerate = false
}

resource "local_file" "project_level_svc_account_key" {
  content  = base64encode("credentials app.terraform.io { token = \"${tfe_team_token.terraform_cloud_operator.token}\" }")
  filename = "./terraform_cloud_operator/team_api_token.b64"
}
