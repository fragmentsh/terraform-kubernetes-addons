<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | ~> 1.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0, != 2.12 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 2.1.3 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_kms"></a> [aws\_kms](#module\_aws\_kms) | terraform-aws-modules/kms/aws | ~> 4.0 |
| <a name="module_deepmerge_addons_final"></a> [deepmerge\_addons\_final](#module\_deepmerge\_addons\_final) | invicton-labs/deepmerge/null | 0.1.6 |
| <a name="module_deepmerge_addons_intermediate"></a> [deepmerge\_addons\_intermediate](#module\_deepmerge\_addons\_intermediate) | invicton-labs/deepmerge/null | 0.1.6 |
| <a name="module_deepmerges"></a> [deepmerges](#module\_deepmerges) | invicton-labs/deepmerge/null | 0.1.6 |
| <a name="module_helm_releases"></a> [helm\_releases](#module\_helm\_releases) | git::https://github.com/wamsatson/terraform-helm-release.git | c70ccf6cdca23862af6a8a960507b8d248cdd0e4 |
| <a name="module_pod_identities"></a> [pod\_identities](#module\_pod\_identities) | terraform-aws-modules/eks-pod-identity/aws | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.kube_manifests](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_namespace.kubernetes_namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.allow_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.default_deny](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_priority_class.priority_classes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/priority_class) | resource |
| [kubernetes_storage_class.kubernetes_storages_classes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubectl_path_documents.kube_path_documents](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/data-sources/path_documents) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_defaults"></a> [addon\_defaults](#input\_addon\_defaults) | Default values for addons | `any` | `{}` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | n/a | `any` | `{}` | no |
| <a name="input_arn-partition"></a> [arn-partition](#input\_arn-partition) | ARN partition | `string` | `""` | no |
| <a name="input_aws"></a> [aws](#input\_aws) | AWS provider customization | `any` | `{}` | no |
| <a name="input_aws-ebs-csi-driver"></a> [aws-ebs-csi-driver](#input\_aws-ebs-csi-driver) | Customize aws-ebs-csi-driver helm chart, see `aws-ebs-csi-driver.tf` | `any` | `{}` | no |
| <a name="input_aws-efs-csi-driver"></a> [aws-efs-csi-driver](#input\_aws-efs-csi-driver) | Customize aws-efs-csi-driver helm chart, see `aws-efs-csi-driver.tf` | `any` | `{}` | no |
| <a name="input_aws-for-fluent-bit"></a> [aws-for-fluent-bit](#input\_aws-for-fluent-bit) | Customize aws-for-fluent-bit helm chart, see `aws-fluent-bit.tf` | `any` | `{}` | no |
| <a name="input_aws-load-balancer-controller"></a> [aws-load-balancer-controller](#input\_aws-load-balancer-controller) | Customize aws-load-balancer-controller chart, see `aws-load-balancer-controller.tf` for supported values | `any` | `{}` | no |
| <a name="input_aws-node-termination-handler"></a> [aws-node-termination-handler](#input\_aws-node-termination-handler) | Customize aws-node-termination-handler chart, see `aws-node-termination-handler.tf` | `any` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_cni-metrics-helper"></a> [cni-metrics-helper](#input\_cni-metrics-helper) | Customize cni-metrics-helper deployment, see `cni-metrics-helper.tf` for supported values | `any` | `{}` | no |
| <a name="input_create_default_priority_classes"></a> [create\_default\_priority\_classes](#input\_create\_default\_priority\_classes) | Whether to create priority classes | `bool` | `false` | no |
| <a name="input_eks"></a> [eks](#input\_eks) | EKS cluster inputs | `any` | `{}` | no |
| <a name="input_karpenter"></a> [karpenter](#input\_karpenter) | Customize karpenter chart, see `karpenter.tf` for supported values | `any` | `{}` | no |
| <a name="input_priority_classes"></a> [priority\_classes](#input\_priority\_classes) | Customize priority classes | `any` | `{}` | no |
| <a name="input_prometheus-cloudwatch-exporter"></a> [prometheus-cloudwatch-exporter](#input\_prometheus-cloudwatch-exporter) | Customize prometheus-cloudwatch-exporter chart, see `prometheus-cloudwatch-exporter.tf` for supported values | `any` | `{}` | no |
| <a name="input_s3-logging"></a> [s3-logging](#input\_s3-logging) | Logging configuration for bucket created by this module | `any` | `{}` | no |
| <a name="input_secrets-store-csi-driver-provider-aws"></a> [secrets-store-csi-driver-provider-aws](#input\_secrets-store-csi-driver-provider-aws) | Enable secrets-store-csi-driver-provider-aws | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags for AWS resources | `map(any)` | `{}` | no |
| <a name="input_yet-another-cloudwatch-exporter"></a> [yet-another-cloudwatch-exporter](#input\_yet-another-cloudwatch-exporter) | Customize yet-another-cloudwatch-exporter chart, see `yet-another-cloudwatch-exporter.tf` for supported values | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
