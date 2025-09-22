locals {
  aws = var.aws

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
    eks_pod_identity = {
      enabled = false
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
      eks_pod_identity = {
        enabled         = true
        service_account = "ebs-csi-controller-sa"
      }
      storage_classes = {
        default = {
          enabled                = true
          name                   = "ebs-sc"
          is_default_class       = true
          storage_provisioner    = "ebs.csi.aws.com"
          volume_binding_mode    = "WaitForFirstConsumer"
          allow_volume_expansion = true
          parameters = {
            type = "gp3"
          }
        }
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
        allow-telemetry = {
          enabled = true
          ports = {
            metrics = {
              port     = "9402"
              protocol = "TCP"
            }
          }
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
      eks_pod_identity = {
        enabled         = true
        service_account = "aws-load-balancer-controller"
      }
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        allow-telemetry = {
          enabled = true
        }
        default-deny = {
          enabled = true
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
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        allow-telemetry = {
          enabled = true
          ports = {
            metrics = {
              port     = "metrics"
              protocol = "TCP"
            }
          }
        }
        default-deny = {
          enabled = true
        }
      }
    }

    external-dns = {
      enabled = false
      namespace = {
        name        = "external-dns"
        create      = true
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "external-dns")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "external-dns")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "external-dns")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "external-dns")].version
      }
      eks_pod_identity = {
        enabled         = true
        service_account = "external-dns"
      }
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        allow-telemetry = {
          enabled = true
          ports = {
            metrics = {
              port     = "http"
              protocol = "TCP"
            }
          }
        }
        default-deny = {
          enabled = true
        }
      }
      route53 = {
        hosted_zone_arns = []
      }
    }

    cluster-autoscaler = {
      enabled = false
      namespace = {
        name        = "cluster-autoscaler"
        create      = true
        labels      = {}
        annotations = {}
      }
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies[*].name, "cluster-autoscaler")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies[*].name, "cluster-autoscaler")].name
        repository = local.helm_dependencies[index(local.helm_dependencies[*].name, "cluster-autoscaler")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies[*].name, "cluster-autoscaler")].version
      }
      eks_pod_identity = {
        enabled         = true
        service_account = "cluster-autoscaler"
      }
      network_policies = {
        allow-namespace = {
          enabled = true
        }
        allow-telemetry = {
          enabled = true
          ports = {
            metrics = {
              port     = "8085"
              protocol = "TCP"
            }
          }
        }
        default-deny = {
          enabled = true
        }
      }
      image = {
        tag        = ""
        repository = ""
      }
    }
  }

  #############################################################################
  # Default custom config that needs computation from locals                  #
  #############################################################################
  addons_base_computed_from_local = {

    aws-ebs-csi-driver = {
      helm_release = {
        values = <<-VALUES
          controller:
            k8sTagClusterId: ${local.cluster_name}
            extraCreateMetadata: true
            priorityClassName: ${try(local.addons_intermediate.aws-ebs-csi-driver.priority_classes.default, "")}
            serviceAccount:
              name: ${local.addons_intermediate.aws-ebs-csi-driver.eks_pod_identity.service_account}
          node:
            tolerateAllTaints: true
            priorityClassName: ${try(local.addons_intermediate.aws-ebs-csi-driver.priority_classes.daemon_set, "")}
          VALUES
      }
    }

    cert-manager = {
      helm_release = {
        values = <<-VALUES
        global:
          priorityClassName: ${try(local.addons_intermediate.cert-manager.priority_classes.default, "")}
        serviceAccount:
            name: ${local.addons_intermediate.cert-manager.eks_pod_identity.service_account}
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
      }
      kubernetes_templates = {
        cluster_issuers = {
          enabled = true
          path    = "${path.module}/templates/cert-manager-cluster-issuers.yaml.tpl"
          vars = {
            aws_region                 = local.aws.region
            acme_email                 = local.addons_intermediate.cert-manager.acme.email
            acme_http01_enabled        = local.addons_intermediate.cert-manager.acme.http01_enabled
            acme_http01_ingress_class  = local.addons_intermediate.cert-manager.acme.http01_ingress_class
            acme_dns01_enabled         = local.addons_intermediate.cert-manager.acme.dns01_enabled
            acme_dns01_assume_role_arn = local.addons_intermediate.cert-manager.acme.dns01_assume_role_arn
          }
        }
      }
    }

    aws-load-balancer-controller = {
      helm_release = {
        values = <<-VALUES
        clusterName: ${local.cluster_name}
        region: ${local.aws.region}
        vpcId: SET_ME_IF_METADATA_SERVICE_IS_NOT_AVAILABLE
        serviceAccount:
          name: ${local.addons_intermediate.aws-load-balancer-controller.eks_pod_identity.service_account}
        VALUES
      }
      kubernetes_manifests = {
        netpol_webhook = {
          enabled   = true
          yaml_body = <<-EOT
            apiVersion: networking.k8s.io/v1
            kind: NetworkPolicy
            metadata:
              name: ${local.addons_intermediate.aws-load-balancer-controller.namespace.name}-allow-webhook
              namespace: ${local.addons_intermediate.aws-load-balancer-controller.namespace.name}
            spec:
              ingress:
              - from:
                - ipBlock:
                    cidr: 0.0.0.0/0
                ports:
                - port: 9443
                  protocol: TCP
              podSelector:
                matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                  - aws-load-balancer-controller
              policyTypes:
              - Ingress
            EOT
        }
      }
    }

    ingress-nginx = {
      helm_release = {
        values = <<-VALUES
        controller:
          allowSnippetAnnotations: true
          enableTopologyAwareRouting: true
          networkPolicy:
            enabled: true
          metrics:
            enabled: true
          updateStrategy:
            type: RollingUpdate
          priorityClassName: ${try(local.addons_intermediate.ingress-nginx.priority_classes.default, "")}
        VALUES
      }
    }

    external-dns = {
      helm_release = {
        values = <<-VALUES
          provider: aws
          txtPrefix: "ext-dns-"
          txtOwnerId: ${local.cluster_name}
          logFormat: json
          policy: sync
          serviceAccount:
            name: ${local.addons_intermediate.external-dns.eks_pod_identity.service_account}
          priorityClassName: ${try(local.addons_intermediate.external-dns.priority_classes.default, "")}
        VALUES
      }
    }

    cluster-autoscaler = {
      helm_release = {
        values = <<-VALUES
          nameOverride: "${local.addons_intermediate.cluster-autoscaler.helm_release.name}"
          autoDiscovery:
            clusterName: ${local.cluster_name}
          awsRegion: ${local.aws.region}
          rbac:
            create: true
            serviceAccount:
              name: ${local.addons_intermediate.cluster-autoscaler.eks_pod_identity.service_account}
          image:
            tag: ${local.addons_intermediate.cluster-autoscaler.image.tag}
          extraArgs:
            balance-similar-node-groups: true
            skip-nodes-with-local-storage: false
            balancing-ignore-label_1: topology.ebs.csi.aws.com/zone
            balancing-ignore-label_2: eks.amazonaws.com/nodegroup
            balancing-ignore-label_3: eks.amazonaws.com/nodegroup-image
            balancing-ignore-label_4: eks.amazonaws.com/sourceLaunchTemplateId
            balancing-ignore-label_5: eks.amazonaws.com/sourceLaunchTemplateVersion
          priorityClassName: ${try(local.addons_intermediate.cluster-autoscaler.priority_classes.default, "")}
        VALUES
      }
    }
  }
}
