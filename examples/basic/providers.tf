
provider "aws" {}

provider "aws" {
  alias  = "audit_us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "audit_eu_west_2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "management_us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "management_eu_west_2"
  region = "eu-west-2"
}
