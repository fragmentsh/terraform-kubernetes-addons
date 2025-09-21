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
}

resource "kubernetes_priority_class" "priority_classes" {
  for_each = { for k, v in local.priority_classes : k => v if v.create }
  metadata {
    name = try(each.value.name, each.key)
  }

  value = each.value.value
}
