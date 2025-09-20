locals {
  tags = var.tags

  #############################################################################
  # Global defaults for all addons                                            #
  #############################################################################
  addon_defaults = {
    enabled = false
    namespace = {
      create      = true
      labels      = {}
      annotations = {}
    }
    eks_pod_identity = {
      enabled = false
    }
    priority_classes = {
      default    = "kubernetes-addons"
      daemon_set = "kubernetes-addons-ds"
    }
    network_policies = {
      allow-namespace = {
        enabled = false
      }
      default-deny = {
        enabled = false
      }
    }
  }

  #############################################################################
  # Defaults per addons                                                       #
  #############################################################################
  addons_base = {

    aws-ebs-csi-driver = {
      enabled = false
      namespace = {
        name        = "kube-system"
        create      = false
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-ebs-csi-driver")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-ebs-csi-driver")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-ebs-csi-driver")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-ebs-csi-driver")].version
      }
      priority_classes = {
        default    = "kubernetes-addons"
        daemon_set = "kubernetes-addons-ds"
      }
      eks_pod_identity = {
        enabled         = true
        service_account = "ebs-csi-controller-sa"
      }
      storage_class = {
        enabled                = true
        name                   = "ebs-sc"
        is_default_class       = false
        storage_provisioner    = "ebs.csi.aws.com"
        volume_binding_mode    = "WaitForFirstConsumer"
        allow_volume_expansion = true
        parameters             = {}
      }
      encryption = {
        enabled              = true
        create_kms_key       = true
        kms_key_alias        = "${local.cluster_name}-aws-ebs-csi-driver"
        existing_kms_key_arn = ""
      }
      kubernetes_manifests = {
        volume_snapshot_class = {
          enabled   = true
          yaml_body = <<-YAML
            apiVersion: snapshot.storage.k8s.io/v1
            kind: VolumeSnapshotClass
            metadata:
              name: csi-aws-vsc
              labels:
                velero.io/csi-volumesnapshot-class: "true"
            driver: ebs.csi.aws.com
            deletionPolicy: Retain
            YAML
        }
      }
    }

    cert-manager = {
      enabled = false
      namespace = {
        name        = "cert-manager"
        create      = true
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "cert-manager")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "cert-manager")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "cert-manager")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "cert-manager")].version
      }
      priority_classes = {
        default    = "kubernetes-addons"
        daemon_set = "kubernetes-addons-ds"
      }
      eks_pod_identity = {
        enabled         = true
        service_account = "cert-manager"
      }
      acme = {
        email                  = "contact@acme.com"
        http01_enabled         = true
        http01_ingress_class   = "nginx"
        dns01_enabled          = true
        dns01_assume_role_arn  = ""
        dns01_hosted_zone_arns = []
      }
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        default-deny = {
          enabled = true
        }
      }
    }

    aws-load-balancer-controller = {
      enabled = false
      namespace = {
        name        = "aws-load-balancer-controller"
        create      = true
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-load-balancer-controller")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-load-balancer-controller")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-load-balancer-controller")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "aws-load-balancer-controller")].version
      }
      priority_classes = {
        default    = "kubernetes-addons"
        daemon_set = "kubernetes-addons-ds"
      }
      eks_pod_identity = {
        enabled         = true
        service_account = "aws-load-balancer-controller"
      }
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        default-deny = {
          enabled = true
        }
        webhook = {
          enabled = true
          pod_selector = {

          }
          policy_types = [
            "Ingress"
          ]


        }
      }
    }

    ingress-nginx = {
      enabled = false
      namespace = {
        name        = "ingress-nginx"
        create      = true
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "ingress-nginx")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "ingress-nginx")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "ingress-nginx")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "ingress-nginx")].version
      }
      priority_classes = {
        default    = "kubernetes-addons"
        daemon_set = "kubernetes-addons-ds"
      }
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        default-deny = {
          enabled = true
        }
      }
    }
  }

  #############################################################################
  # Default custom config that needs interpolation                            #
  #############################################################################
  addons_computed_from_local = {

    aws-ebs-csi-driver = {
      helm_values = <<-VALUES
        controller:
          k8sTagClusterId: ${local.cluster_name}
          extraCreateMetadata: true
          priorityClassName: ${try(local.addons.aws-ebs-csi-driver.priority_classes.default, "")}
          serviceAccount:
            name: ${local.addons.aws-ebs-csi-driver.eks_pod_identity.service_account}
        node:
          tolerateAllTaints: true
          priorityClassName: ${try(local.addons.aws-ebs-csi-driver.priority_classes.daemon_set, "")}
        VALUES
    }

    cert-manager = {
      helm_values = <<-VALUES
        global:
          priorityClassName: ${try(local.addons.cert-manager.priority_classes.default, "")}
        serviceAccount:
            name: ${local.addons.cert-manager.eks_pod_identity.service_account}
        crds:
          enabled: true
        webhook:
          networkPolicy:
            enabled: true
        ingressShim:
          defaultIssuerName: letsencrypt
          defaultIssuerKind: ClusterIssuer
          defaultIssuerGroup: cert-manager.io
        featureGates: "StableCertificateRequestName=true"
        extraArgs:
          - "--enable-certificate-owner-ref"
        VALUES
      kubernetes_templates = {
        cluster_issuers = {
          enabled = true
          path    = "${path.module}/templates/cert-manager-cluster-issuers.yaml.tpl"
          vars = {
            aws_region                 = data.aws_region.current.region
            acme_email                 = local.addons.cert-manager.acme.email
            acme_http01_enabled        = local.addons.cert-manager.acme.http01_enabled
            acme_http01_ingress_class  = local.addons.cert-manager.acme.http01_ingress_class
            acme_dns01_enabled         = local.addons.cert-manager.acme.dns01_enabled
            acme_dns01_assume_role_arn = local.addons.cert-manager.acme.dns01_assume_role_arn
          }
        }
      }
    }

    aws-load-balancer-controller = {
      helm_values = <<-VALUES
        clusterName: ${local.cluster_name}
        region: ${data.aws_region.current.region}
        vpcId: SET_ME_IF_METADATA_SERVICE_IS_NOT_AVAILABLE
        serviceAccount:
          name: ${local.addons.aws-load-balancer-controller.eks_pod_identity.service_account}
        VALUES
    }

    ingress-nginx = {
      helm_values = <<-VALUES
        controller:
          allowSnippetAnnotations: true
          enableTopologyAwareRouting: true
          networkPolicy:
            enabled: true
          metrics:
            enabled: true
          updateStrategy:
            type: RollingUpdate
          priorityClassName: ${try(local.addons.ingress-nginx.priority_classes.default, "")}
        VALUES
    }
  }
}
