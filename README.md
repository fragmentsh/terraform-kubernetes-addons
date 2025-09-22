# terraform-kubernetes-addons

[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/terraform-kubernetes-addons)
[![terraform-kubernetes-addons](https://github.com/fragmentsh/terraform-kubernetes-addons/workflows/terraform-kubernetes-addons/badge.svg)](https://github.com/fragmentsh/terraform-kubernetes-addons/actions?query=workflow%3Aterraform-kubernetes-addons)

## Modules

Modules are used for specific cloud provider configuration.

Any contribution supporting a new cloud provider is welcomed.

- [Generic](./modules/generic)
- [AWS](./modules/aws)
- [Scaleway](./modules/scaleway)
- [GCP](./modules/google)
- [Azure](./modules/azure)

## Pre-commit

```
pre-commit install
pre-commit run -a
```

Code formatting and documentation for variables and outputs is generated using
[pre-commit-terraform
hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses
[terraform-docs](https://github.com/segmentio/terraform-docs).

## Contributing

Report issues/questions/feature requests on in the
[issues](https://github.com/fragmentsh/terraform-kubernetes-addons/issues/new)
section.

Full contributing [guidelines are covered
here](https://github.com/fragmentsh/terraform-kubernetes-addons/blob/master/.github/CONTRIBUTING.md).
