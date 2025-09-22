resource "tls_private_key" "this" {
  for_each = { for k, v in local.addons :
    k => v
    if v.enabled
    && k == "flux"
    && v.github.deploy_key.create
  }
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "github_repository" "this" {
  for_each = { for k, v in local.addons :
    k => v
    if v.enabled
    && k == "flux"
    && v.github.repository.create
  }
  name       = each.value.github.repository.name
  visibility = each.value.github.repository.name
  auto_init  = each.value.github.repository.auto_init
}

resource "github_branch_default" "this" {
  for_each = { for k, v in local.addons :
    k => v
    if v.enabled
    && k == "flux"
    && v.github.repository.create
  }
  repository = github_repository.this[each.key]
  branch     = each.value.github.repository.branch
}

resource "github_repository_deploy_key" "this" {
  for_each = { for k, v in local.addons :
    k => v
    if v.enabled
    && k == "flux"
    && v.github.deploy_key.create
  }
  title      = try(each.value.github.deploy_key.title, "flux-${local.cluster_name}")
  repository = try(github_repository.this[each.key], each.value.github.repository.name)
  key        = tls_private_key.this[each.key].public_key_openssh
  read_only  = each.value.github.deploy_key.read_only
}

resource "flux_bootstrap_git" "this" {
  for_each = { for k, v in local.addons :
    k => v
    if v.enabled
    && k == "flux"
    && v.bootstrap.enabled
  }

  depends_on = [
    kubernetes_namespace.kubernetes_namespaces,
    github_repository_deploy_key.this
  ]

  cluster_domain          = try(local.addons.flux.bootstrap.cluster_domain, null)
  components              = try(local.addons.flux.bootstrap.components, null)
  components_extra        = try(local.addons.flux.bootstrap.components_extra, null)
  delete_git_manifests    = try(local.addons.flux.bootstrap.delete_git_manifests, null)
  disable_secret_creation = try(local.addons.flux.bootstrap.disable_secret_creation, null)
  embedded_manifests      = try(local.addons.flux.bootstrap.embedded_manifests, null)
  image_pull_secret       = try(local.addons.flux.bootstrap.image_pull_secret, null)
  interval                = try(local.addons.flux.bootstrap.interval, null)
  keep_namespace          = try(local.addons.flux.bootstrap.keep_namespace, null)
  kustomization_override  = try(local.addons.flux.bootstrap.kustomization_override, null)
  log_level               = try(local.addons.flux.bootstrap.log_level, null)
  namespace               = try(local.addons.flux.bootstrap.namespace, null)
  network_policy          = try(local.addons.flux.bootstrap.network_policy, null)
  path                    = try(local.addons.flux.bootstrap.path, null)
  recurse_submodules      = try(local.addons.flux.bootstrap.recurse_submodules, null)
  registry                = try(local.addons.flux.bootstrap.registry, null)
  registry_credentials    = try(local.addons.flux.bootstrap.registry_credentials, null)
  secret_name             = try(local.addons.flux.bootstrap.secret_name, null)
  timeouts                = try(local.addons.flux.bootstrap.timeouts, null)
  toleration_keys         = try(local.addons.flux.bootstrap.toleration_keys, null)
  version                 = try(local.addons.flux.bootstrap.version, null)
  watch_all_namespaces    = try(local.addons.flux.bootstrap.watch_all_namespaces, null)
}
