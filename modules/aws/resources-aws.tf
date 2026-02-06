locals {
  addons_storage_classes = merge(
    [
      for addon_name, addon in local.addons : {
        for sc_name, sc in try(addon.storage_classes, {}) :
        "${addon_name}-${sc_name}" => {
          storage_class = sc
          encryption    = addon.encryption
        }
        if try(sc.enabled, false)
      }
      if try(addon.enabled, false)
    ]...
  )
}

resource "helm_release" "this" {

  for_each = {
    for k, v in local.addons :
    k => v
    if v.helm_release.enabled
    && v.enabled
  }
  namespace  = each.value.namespace.name
  repository = each.value.helm_release.repository

  name                       = try(each.value.helm_release.name, each.key)
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
  values = [
    try(each.value.helm_release.values, null),
    try(each.value.helm_release.extra_values, null),
    try((each.value.iam.irsa.enabled && strcontains(each.key, "aws-ebs-csi-driver")), false) ? yamlencode({
      controller = {
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = module.irsa[each.key].arn
          }
        }
      }
    }) : "",
    try((each.value.iam.irsa.enabled && strcontains(each.key, "aws-load-balancer-controller")), false) ? yamlencode({
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.irsa[each.key].arn
        }
      }
    }) : "",
    try((each.value.iam.irsa.enabled && strcontains(each.key, "cluster-autoscaler")), false) ? yamlencode({
      rbac = {
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = module.irsa[each.key].arn
          }
        }
      }
    }) : "",
    try((each.value.iam.irsa.enabled && strcontains(each.key, "external-dns")), false) ? yamlencode({
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.irsa[each.key].arn
        }
      }
    }) : "",
  ]

  depends_on = [
    kubernetes_namespace.kubernetes_namespaces,
    module.pod_identities,
    module.irsa
  ]
}

module "pod_identities" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.iam.eks_pod_identity.enabled, false)
  }

  name = each.key

  association_defaults = {
    namespace       = each.value.namespace.name
    service_account = each.value.iam.service_account
    tags            = try(local.aws.tags, {})
    cluster_name    = local.cluster_name
  }

  associations = {
    this = {}
  }

  # EBS CSI Driver
  attach_aws_ebs_csi_policy = each.key == "aws-ebs-csi-driver" ? true : false
  aws_ebs_csi_kms_arns      = try(each.value.encryption.enabled, false) ? [try(module.aws_kms[each.key].key_arn, each.value.encryption.existing_kms_key_arn)] : []

  # Cert Manager
  attach_cert_manager_policy    = each.key == "cert-manager"
  cert_manager_hosted_zone_arns = try(each.value.acme.dns01_enabled, false) ? each.value.acme.dns01_hosted_zone_arns : []

  # AWS Load Balancer Controller
  attach_aws_lb_controller_policy = each.key == "aws-load-balancer-controller" ? true : false

  # Cluster Autoscaler
  attach_cluster_autoscaler_policy = each.key == "cluster-autoscaler" ? true : false
  cluster_autoscaler_cluster_names = [local.cluster_name]

  # External DNS
  attach_external_dns_policy    = each.key == "external-dns" ? true : false
  external_dns_hosted_zone_arns = try(each.value.route53.hosted_zone_arns, [])

  # Velero
  attach_velero_policy = each.key == "velero" ? true : false

  tags = local.aws.tags
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.iam.irsa.enabled, false)
  }

  name = each.key

  attach_ebs_csi_policy = strcontains(each.key, "aws-ebs-csi-driver")
  ebs_csi_kms_cmk_arns  = try(each.value.encryption.enabled, false) ? [try(module.aws_kms[each.key].key_arn, each.value.encryption.existing_kms_key_arn)] : []

  attach_cert_manager_policy    = strcontains(each.key, "cert-manager")
  cert_manager_hosted_zone_arns = try(each.value.acme.dns01_enabled, false) ? each.value.acme.dns01_hosted_zone_arns : []

  attach_load_balancer_controller_policy = strcontains(each.key, "aws-load-balancer-controller")

  attach_external_dns_policy    = strcontains(each.key, "external-dns")
  external_dns_hosted_zone_arns = try(each.value.route53.hosted_zone_arns, [])

  attach_cluster_autoscaler_policy = strcontains(each.key, "cluster-autoscaler")
  cluster_autoscaler_cluster_names = [local.cluster_name]


  oidc_providers = {
    this = {
      provider_arn               = each.value.iam.irsa.oidc_provider_arn
      namespace_service_accounts = each.value.iam.irsa.namespace_service_accounts
    }
  }

  tags = try(local.aws.tags, {})
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

  tags = try(local.aws.tags, {})
}

resource "kubernetes_storage_class" "kubernetes_storages_classes" {
  for_each = local.addons_storage_classes
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
      kmsKeyId  = each.value.encryption.enabled ? try(module.aws_kms[each.key].key_arn, each.value.encryption.existing_kms_key_arn, "") : ""
    },
    each.value.storage_class.parameters
  )
}
