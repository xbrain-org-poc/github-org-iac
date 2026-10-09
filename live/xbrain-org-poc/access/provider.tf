# Supply authentication through GITHUB_TOKEN. Never put a token in this file.
# Clear GITHUB_OWNER and GITHUB_ORGANIZATION before running: in provider 6.x
# those environment variables can override this explicit sandbox owner.
provider "github" {
  owner = var.github_org
}
