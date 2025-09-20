locals {
  addon_names     = setunion(keys(local.addons_base), keys(local.addons_override))
  addons_override = var.addons
  addons = {
    for name, m in module.deepmerge_addons :
    name => m.merged
  }
  deepmerges = {}
}

module "deepmerge_addons" {
  source  = "invicton-labs/deepmerge/null"
  version = "0.1.6" # pin a version you trust

  for_each = local.addon_names

  # Merge order matters: later maps override earlier ones
  maps = [
    local.addon_defaults,
    lookup(local.addons_base, each.key, {}),
    lookup(local.addons_override, each.key, {}),
  ]
}

module "deepmerges" {
  for_each = local.deepmerges
  source   = "invicton-labs/deepmerge/null"
  version  = "0.1.6"

  maps = each.value.maps
}
