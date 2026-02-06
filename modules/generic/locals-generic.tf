locals {
  #############################################################################
  # Global defaults for all addons                                            #
  #############################################################################
  addon_defaults_defaults = {
    enabled = false
    namespace = {
      create      = true
      labels      = {}
      annotations = {}
    }
    priority_classes = {
      default    = ""
      daemon_set = ""
    }
    network_policies = {
      allow-namespace = {
        enabled = false
      }
      default-deny = {
        enabled = false
      }
      allow-telemetry = {
        enabled   = false
        namespace = "telemetry"
      }
    }
  }

  addons_base = {
    flux-operator = {
      enabled = false
      namespace = {
        name        = "flux-system"
        create      = true
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-operator")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-operator")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-operator")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-operator")].version
      }
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        allow-telemetry = {
          enabled = true
          ports = {
            metrics = {
              port     = 8080
              protocol = "TCP"
            }
          }
        }
        default-deny = {
          enabled = true
        }
      }
    }
    flux-instance = {
      enabled = false
      namespace = {
        name        = "flux-system"
        create      = false
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-instance")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-instance")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-instance")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "flux-instance")].version
      }
    }
  }

  addons_base_computed_from_local = {}
}
