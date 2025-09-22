module "helm_releases" {

  # TODO: fix when new release
  #source  = "terraform-module/release/helm"
  #version = "~> 2.9.0"
  source = "git::https://github.com/wamsatson/terraform-helm-release.git?ref=c70ccf6cdca23862af6a8a960507b8d248cdd0e4"

  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
  }
  namespace  = each.value.namespace.name
  repository = each.value.helm_release.repository

  app = {
    deploy                     = try(each.value.helm_release.deploy, true)
    name                       = each.value.helm_release.name
    description                = "Helm release for ${each.key} on cluster ${local.cluster_name}"
    version                    = each.value.helm_release.version
    chart                      = each.value.helm_release.chart
    create_namespace           = try(each.value.helm_release.create_namespace, false)
    force_update               = try(each.value.helm_release.force_update, false)
    wait                       = try(each.value.helm_release.wait, true)
    wait_for_jobs              = try(each.value.helm_release.wait_for_jobs, false)
    recreate_pods              = try(each.value.helm_release.recreate_pods, false)
    max_history                = try(each.value.helm_release.max_history, 5)
    lint                       = try(each.value.helm_release.lint, true)
    cleanup_on_fail            = try(each.value.helm_release.cleanup_on_fail, true)
    disable_webhooks           = try(each.value.helm_release.disable_webhooks, false)
    verify                     = try(each.value.helm_release.verify, false)
    reuse_values               = try(each.value.helm_release.reuse_values, false)
    reset_values               = try(each.value.helm_release.reset_values, false)
    atomic                     = try(each.value.helm_release.atomic, false)
    skip_crds                  = try(each.value.helm_release.skip_crds, false)
    render_subchart_notes      = try(each.value.helm_release.render_subchart_notes, true)
    disable_openapi_validation = try(each.value.helm_release.disable_openapi_validation, false)
    dependency_update          = try(each.value.helm_release.dependency_update, false)
    replace                    = try(each.value.helm_release.replace, false)
    timeout                    = try(each.value.helm_release.timeout, 300)
  }
  values = [
    try(each.value.helm_release.values, null),
    try(each.value.helm_release.extra_values, null),
  ]
}
