locals {
  tags = var.tags

  addons_base = {
    aws-ebs-csi-driver = {
      enabled          = false
      namespace        = "kube-system"
      create_namespace = false
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-ebs-csi-driver")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-ebs-csi-driver")].name
        repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-ebs-csi-driver")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-ebs-csi-driver")].version
      }
      priority_classes = {
        default    = "kubernetes-addons"
        daemon_set = "kubernetes-addons-ds"
      }
      eks_pod_identity = {
        create          = true
        service_account = "ebs-csi-controller-sa"
      }
      storage_class = {
        create                 = true
        name                   = "ebs-sc"
        is_default_class       = false
        storage_provisioner    = "ebs.csi.aws.com"
        volume_binding_mode    = "WaitForFirstConsumer"
        allow_volume_expansion = true
        parameters             = {}
      }
      default_network_policy = {
        create = true
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
      enabled          = false
      namespace        = "cert-manager"
      create_namespace = true
      helm_release = {
        name       = local.helm_dependencies[index(local.helm_dependencies.*.name, "cert-manager")].name
        chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "cert-manager")].name
        repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "cert-manager")].repository
        version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "cert-manager")].version
      }
      priority_classes = {
        default    = "kubernetes-addons"
        daemon_set = "kubernetes-addons-ds"
      }
      eks_pod_identity = {
        create          = true
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
    }
  }

  addons_override = var.addons

  deepmerges = {
    addons = {
      maps = [
        local.addons_base,
        local.addons_override,
      ]
    }
  }

  addons = module.deepmerge.addons.merged

  addons_computed_from_local = {
    aws-ebs-csi-driver = {
      helm_values = <<-VALUES
        controller:
          k8sTagClusterId: ${local.cluster_name}
          extraCreateMetadata: true
          priorityClassName: ${try(local.addons.aws-ebs-csi-driver.priority_classes.default, "")}
          serviceAccount:
            name: ${local.addons.aws-ebs-csi-driver["eks_pod_identity"]["service_account"]}
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
            name: ${local.addons.cert-manager["eks_pod_identity"]["service_account"]}
        crds:
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
  }
}
