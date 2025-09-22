locals {

  addon_names_intermediate = setunion(keys(local.addons_base), keys(local.addons_user_override))
  addon_names_final        = setunion(keys(local.addons_intermediate), keys(local.addons_base_computed_from_local))
  addons_user_override     = var.addons
  addons_intermediate = {
    for k, v in module.deepmerge_addons_intermediate :
    k => v.merged
  }
  addons = {
    for k, v in module.deepmerge_addons_final :
    k => v.merged
  }
  deepmerges = {}
}

module "deepmerge_addons_intermediate" {
  source  = "invicton-labs/deepmerge/null"
  version = "0.1.6" # pin a version you trust

  for_each = local.addon_names_intermediate

  # Merge order matters: later maps override earlier ones
  maps = [
    local.addon_defaults_defaults,
    var.addon_defaults,
    lookup(local.addons_base, each.key, {}),
    lookup(local.addons_user_override, each.key, {}),
  ]
}

module "deepmerge_addons_final" {
  source  = "invicton-labs/deepmerge/null"
  version = "0.1.6"

  for_each = local.addon_names_final

  # ORDER MATTERS: put computed first, RAW last so user overrides in RAW win
  maps = [
    lookup(local.addons_base_computed_from_local, each.key, {}),
    lookup(local.addons_intermediate, each.key, {}),
  ]
}


module "deepmerges" {
  for_each = local.deepmerges
  source   = "invicton-labs/deepmerge/null"
  version  = "0.1.6"

  maps = each.value.maps
}
