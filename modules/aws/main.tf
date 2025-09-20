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
  namespace  = each.value.namespace
  repository = each.value.helm_release.repository

  app = {
    deploy                     = try(each.value.helm_release.deploy, true)
    name                       = each.value.helm_release.name
    description                = "Helm release for ${each.key} on cluster ${local.cluster_name}"
    version                    = each.value.helm_release.version
    chart                      = each.value.helm_release.chart
    force_update               = try(each.value.helm_release.force_update, false)
    wait                       = try(each.value.helm_release.wait, true)
    wait_for_jobs              = try(each.value.helm_release.wait_for_jobs, false)
    recreate_pods              = try(each.value.helm_release.recreate_pods, false)
    max_history                = try(each.value.helm_release.max_history, 5)
    lint                       = try(each.value.helm_release.lint, true)
    cleanup_on_fail            = try(each.value.helm_release.cleanup_on_fail, false)
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
    local.addons_computed_from_local[each.key].helm_values,
    try(each.value.helm_release.values, ""),
  ]

  depends_on = [
    module.pod_identities,
  ]
}


module "pod_identities" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.eks-pod-identity.create, false)
  }

  name = "${local.cluster_name}-${each.key}"

  # EBS CSI Driver
  attach_aws_ebs_csi_policy = each.key == "aws-ebs-csi-driver" ? true : false
  aws_ebs_csi_kms_arns      = try(each.value.encryption.enabled)

  # Cert Manager
  attach_cert_manager_policy    = each.key == "cert-manager"
  cert_manager_hosted_zone_arns = try(each.value.acme.dns01_enabled, false) ? each.value.acme.dns01_hosted_zone_arns : []


  #attach_amazon_managed_service_prometheus_policy          = try(each.value.attach_amazon_managed_service_prometheus_policy, var.defaults.attach_amazon_managed_service_prometheus_policy, false)
  #attach_aws_appmesh_controller_policy                     = try(each.value.attach_aws_appmesh_controller_policy, var.defaults.attach_aws_appmesh_controller_policy, false)
  #attach_aws_appmesh_envoy_proxy_policy                    = try(each.value.attach_aws_appmesh_envoy_proxy_policy, var.defaults.attach_aws_appmesh_envoy_proxy_policy, false)
  #attach_aws_cloudwatch_observability_policy               = try(each.value.attach_aws_cloudwatch_observability_policy, var.defaults.attach_aws_cloudwatch_observability_policy, false)
  #attach_aws_efs_csi_policy                                = try(each.value.attach_aws_efs_csi_policy, var.defaults.attach_aws_efs_csi_policy, false)
  #attach_aws_fsx_lustre_csi_policy                         = try(each.value.attach_aws_fsx_lustre_csi_policy, var.defaults.attach_aws_fsx_lustre_csi_policy, false)
  #attach_aws_gateway_controller_policy                     = try(each.value.attach_aws_gateway_controller_policy, var.defaults.attach_aws_gateway_controller_policy, false)
  #attach_aws_lb_controller_policy                          = try(each.value.attach_aws_lb_controller_policy, var.defaults.attach_aws_lb_controller_policy, false)
  #attach_aws_lb_controller_targetgroup_binding_only_policy = try(each.value.attach_aws_lb_controller_targetgroup_binding_only_policy, var.defaults.attach_aws_lb_controller_targetgroup_binding_only_policy, false)
  #attach_aws_node_termination_handler_policy               = try(each.value.attach_aws_node_termination_handler_policy, var.defaults.attach_aws_node_termination_handler_policy, false)
  #attach_aws_privateca_issuer_policy                       = try(each.value.attach_aws_privateca_issuer_policy, var.defaults.attach_aws_privateca_issuer_policy, false)
  #attach_aws_vpc_cni_policy                                = try(each.value.attach_aws_vpc_cni_policy, var.defaults.attach_aws_vpc_cni_policy, false)
  #attach_cluster_autoscaler_policy                         = try(each.value.attach_cluster_autoscaler_policy, var.defaults.attach_cluster_autoscaler_policy, false)
  #attach_custom_policy                                     = try(each.value.attach_custom_policy, var.defaults.attach_custom_policy, false)
  #attach_external_dns_policy                               = try(each.value.attach_external_dns_policy, var.defaults.attach_external_dns_policy, false)
  #attach_external_secrets_policy                           = try(each.value.attach_external_secrets_policy, var.defaults.attach_external_secrets_policy, false)
  #attach_mountpoint_s3_csi_policy                          = try(each.value.attach_mountpoint_s3_csi_policy, var.defaults.attach_mountpoint_s3_csi_policy, false)
  #attach_velero_policy                                     = try(each.value.attach_velero_policy, var.defaults.attach_velero_policy, false)

  tags = local.tags
}

resource "kubernetes_storage_class" "kubernetes_storages_classes" {
  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.storage_class.create, false)
  }
  metadata {
    name = each.value.storage_class.name
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = tostring(each.value.storage_class.is_default_class)
    }
  }
  storage_provisioner    = each.value.storage_class.storage_provisioner
  volume_binding_mode    = each.value.storage_class.volume_binding_mode
  allow_volume_expansion = each.value.storage_class.allow_volume_expansion

  parameters = merge(
    {
      encrypted = each.value.encryption.enabled
      kmsKeyId  = each.value.encryption.enabled ? try(module.aws_kms[each.key].key_arn, each.value.encryption.existing_kms_key_arn) : ""
    },
    each.value.storage_class.parameters
  )
}

module "aws_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.encryption.enabled, false)
    && try(v.encryption.create_kms_key, false)
  }

  description = "KMS key for ${each.key} on cluster ${local.cluster_name}"

  aliases = [
    each.value.encryption.kms_key_alias
  ]

  tags = local.tags
}

locals {
  addons_kubernetes_manifests = merge(
    [
      for addon_name, addon in local.addons : {
        for manifest_name, manifest in try(addon.kubernetes_manifests, {}) :
        "${addon_name}-${manifest_name}" => {
          yaml_body = manifest.yaml_body
        }
        if try(manifest.enabled, false)
      }
      if try(addon.enabled, false)
    ]...
  )
  addons_kubernetes_templates = merge(
    [
      for addon_name, addon in local.addons_computed_from_local : {
        for tpl_name, tpl in try(addon.kubernetes_templates, {}) :
        "${addon_name}-${tpl_name}" => {
          path = tpl.path
          vars = tpl.vars
        }
        if try(tpl.enabled, false)
      }
      if try(addon.enabled, false)
    ]...
  )
  addons_kubernetes_templates_rendered = merge(
    [
      for key, ds in data.kubectl_path_documents.kube_path_documents : {
        for idx, doc in try(ds.documents, []) :
        "${key}-doc-${idx}" => {
          yaml_body = doc
        }
      }
    ]...
  )
  addons_all_kubernetes_manifests = merge(
    local.addons_kubernetes_manifests,
    local.addons_kubernetes_templates_rendered,
  )
}

resource "kubectl_manifest" "kube_manifests" {
  for_each          = local.addons_all_kubernetes_manifests
  yaml_body         = each.value.yaml_body
  server_side_apply = true
  depends_on = [
    module.helm_releases,
  ]
}

data "kubectl_path_documents" "kube_path_documents" {
  for_each = local.addons_kubernetes_templates
  pattern  = each.value.path
  vars     = each.value.vars
}
