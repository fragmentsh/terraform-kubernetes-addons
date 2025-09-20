locals {
  cluster_name      = var.cluster_name
  helm_dependencies = yamldecode(file("${path.module}/helm-dependencies.yaml"))["dependencies"]
}
