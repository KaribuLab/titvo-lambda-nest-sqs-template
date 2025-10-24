locals {
  region = get_env("AWS_REGION")
  stage  = get_env("AWS_STAGE")
  stages = {
    localstack = {
      name = "Localstack"
    }
    test = {
      name = "Testing"
    }
    prod = {
      name = "Production"
    }
  }
  service_name   = "{{.Inputs.service_name|toLowerCase}}"
  service_bucket = "${local.service_name}-${local.region}"
  log_retention  = 7
  parameter_path = "{{.Inputs.parameter_path|toLowerCase}}"
  common_tags    = {}
}
