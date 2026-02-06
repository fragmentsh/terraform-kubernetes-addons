locals {

  create_default_priority_classes = var.create_default_priority_classes

  priority_classes = merge({
    kubernetes-addons-ds = {
      create = local.create_default_priority_classes
      name   = "kubernetes-addons-ds"
      value  = "10000"
    }
    kubernetes-addons = {
      create = local.create_default_priority_classes
      name   = "kubernetes-addons"
      value  = "9000"
    }
    },
    var.priority_classes
  )

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
      for addon_name, addon in local.addons : {
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

resource "kubernetes_namespace" "kubernetes_namespaces" {
  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.namespace.create, false)
  }

  metadata {
    annotations = each.value.namespace.annotations

    labels = merge({
      "kubernetes.io/metadata.name" = each.value.namespace.name
      },
      each.value.namespace.labels
    )

    name = each.value.namespace.name
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }
}

resource "kubernetes_priority_class" "priority_classes" {
  for_each = { for k, v in local.priority_classes : k => v if v.create }
  metadata {
    name = try(each.value.name, each.key)
  }

  value = each.value.value
}


resource "kubernetes_network_policy" "default_deny" {
  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.network_policies.default-deny.enabled, false)
  }

  metadata {
    name      = "${each.key}-default-deny"
    namespace = each.value.namespace.name
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_namespace" {
  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.network_policies.allow-namespace.enabled, false)
  }

  metadata {
    name      = "${each.key}-allow-namespace"
    namespace = each.value.namespace.name
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = each.value.namespace.name
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_telemetry" {
  for_each = {
    for k, v in local.addons :
    k => v
    if v.enabled
    && try(v.network_policies.allow-telemetry.enabled, false)
  }

  metadata {
    name      = "${each.key}-allow-telemetry"
    namespace = each.value.namespace.name
  }

  spec {
    pod_selector {
    }

    ingress {
      dynamic "ports" {
        for_each = try(each.value.network_policies.allow-telemetry.ports, {})
        content {
          protocol = try(ports.value.protocol, "TCP")
          port     = tostring(ports.value.port)
        }
      }

      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = each.value.network_policies.allow-telemetry.namespace
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubectl_manifest" "kube_manifests" {
  for_each          = local.addons_all_kubernetes_manifests
  yaml_body         = each.value.yaml_body
  server_side_apply = true
  depends_on = [
    helm_release.this,
  ]
}

data "kubectl_path_documents" "kube_path_documents" {
  for_each = local.addons_kubernetes_templates
  pattern  = each.value.path
  vars     = each.value.vars
}
