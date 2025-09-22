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

  addons_base = {}

  addons_base_computed_from_local = {}
}
