module "deepmerge" {
  for_each = local.deepmerges
  source   = "invicton-labs/deepmerge/null"
  version  = "0.1.6"

  maps = each.value.maps
}
