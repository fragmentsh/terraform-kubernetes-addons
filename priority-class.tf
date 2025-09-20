locals {

  disable_priority_classes = var.disable_priority_classes

  priority_classes = merge({
    kubernetes-addons-ds = {
      create = true
      name   = "kubernetes-addons-ds"
      value  = "10000"
    }
    kubernetes-addons = {
      create = true
      name   = "kubernetes-addons"
      value  = "9000"
    }
    },
    var.priority_classes
  )
}

resource "kubernetes_priority_class" "priority_classes" {
  for_each = { for k, v in local.priority_classes : k => v if v.create && !local.disable_priority_classes }
  metadata {
    name = try(each.value.name, each.key)
  }

  value = each.value.value
}
