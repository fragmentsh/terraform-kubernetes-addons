# terraform-kubernetes-addons

[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/terraform-kubernetes-addons)
[![terraform-kubernetes-addons](https://github.com/fragmentsh/terraform-kubernetes-addons/workflows/terraform-kubernetes-addons/badge.svg)](https://github.com/fragmentsh/terraform-kubernetes-addons/actions?query=workflow%3Aterraform-kubernetes-addons)

## Submodules

Submodules are used for specific cloud provider configuration such as IAM role for
AWS. For a Kubernetes vanilla cluster, generic addons should be used.

Any contribution supporting a new cloud provider is welcomed.

- [AWS](./modules/aws)
- [Scaleway](./modules/scaleway)
- [GCP](./modules/google)
- [Azure](./modules/azure)

## Doc generation

Code formatting and documentation for variables and outputs is generated using
[pre-commit-terraform
hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses
[terraform-docs](https://github.com/segmentio/terraform-docs).

Follow [these
instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install)
to install pre-commit locally.

And install `terraform-docs` with `go get github.com/segmentio/terraform-docs`
or `brew install terraform-docs`.

## Contributing

Report issues/questions/feature requests on in the
[issues](https://github.com/fragmentsh/terraform-kubernetes-addons/issues/new)
section.

Full contributing [guidelines are covered
here](https://github.com/fragmentsh/terraform-kubernetes-addons/blob/master/.github/CONTRIBUTING.md).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_flux"></a> [flux](#requirement\_flux) | ~> 1.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0, != 2.12 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0, != 2.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_priority_class.priority_classes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/priority_class) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_defaults"></a> [addon\_defaults](#input\_addon\_defaults) | Default values for addons | `any` | `{}` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | n/a | `any` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Kubernetes cluster | `string` | n/a | yes |
| <a name="input_create_default_priority_classes"></a> [create\_default\_priority\_classes](#input\_create\_default\_priority\_classes) | Whether to create priority classes | `bool` | `false` | no |
| <a name="input_priority_classes"></a> [priority\_classes](#input\_priority\_classes) | Customize priority classes | `any` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
