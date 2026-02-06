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
    cilium = {
      enabled = false
      namespace = {
        name        = "kube-system"
        create      = false
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "cilium")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "cilium")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "cilium")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "cilium")].version
      }
    }
    aws-cloud-controller-manager = {
      enabled = false
      namespace = {
        name        = "kube-system"
        create      = false
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-cloud-controller-manager")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-cloud-controller-manager")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-cloud-controller-manager")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-cloud-controller-manager")].version
      }
    }
  }

  addons_base_computed_from_local = {
    cilium = {
      helm_release = {
        values = <<-VALUES
          cgroup:
            autoMount:
              enabled: false
            hostRoot: /sys/fs/cgroup
          hubble:
            relay:
              enabled: true
            ui:
              enabled: true
          ipam:
            mode: kubernetes
          k8sServiceHost: localhost
          k8sServicePort: 7445
          kubeProxyReplacement: true
          policyCIDRMatchMode: nodes
          securityContext:
            capabilities:
              ciliumAgent:
              - CHOWN
              - KILL
              - NET_ADMIN
              - NET_RAW
              - IPC_LOCK
              - SYS_ADMIN
              - SYS_RESOURCE
              - DAC_OVERRIDE
              - FOWNER
              - SETGID
              - SETUID
              cleanCiliumState:
              - NET_ADMIN
              - SYS_ADMIN
              - SYS_RESOURCE

        VALUES
      }
    }
    aws-cloud-controller-manager = {
      helm_release = {
        values = <<-VALUES
        hostNetworking: true
        args:
          - --v=2
          - --cloud-provider=aws
          - --controllers=cloud-node-lifecycle-controller
          - --cluster-name=${var.cluster_name}
        VALUES
      }
    }
  }
}
