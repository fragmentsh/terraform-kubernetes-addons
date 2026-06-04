# terraform-kubernetes-addons

<p align="center">
  <a href="https://github.com/semantic-release/terraform-kubernetes-addons"><img alt="semantic-release" src="https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg"></a>
  <a href="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/pre-commit.yml"><img alt="Pre-Commit" src="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/pre-commit.yml/badge.svg"></a>
  <a href="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/pr-title.yml"><img alt="Validate PR title" src="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/pr-title.yml/badge.svg"></a>
  <a href="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/release.yml"><img alt="Release" src="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/release.yml/badge.svg"></a>
  <a href="https://github.com/shardlabsxyz/terraform-kubernetes-addons/releases"><img alt="Latest Release" src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Fshardlabsxyz%2Fterraform-kubernetes-addons%2Freleases%2Flatest&amp;query=%24.tag_name&amp;label=release"></a>
  <a href="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/stale-actions.yaml"><img alt="Stale actions" src="https://github.com/shardlabsxyz/terraform-kubernetes-addons/actions/workflows/stale-actions.yaml/badge.svg"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
  <a href="https://opentofu.org/"><img alt="OpenTofu compatible" src="https://img.shields.io/badge/OpenTofu-compatible-FFDA18"></a>
</p>

Reusable Terraform/OpenTofu modules for installing and managing Kubernetes addons across cloud providers.

The project keeps provider-specific wiring in separate modules, while common addon configuration is shared from `common/`. The AWS module is currently documented and validated in CI; additional cloud-provider modules can be added under `modules/` as they mature.

## Compatibility

- Terraform `>= 1.13.0`
- OpenTofu `>= 1.11.0`
- Tool versions are pinned in `mise.toml`

OpenTofu compatibility is implemented with `.tofu` override files where needed. Generated module documentation intentionally uses the Terraform view of a module so provider and requirement tables stay stable.

## Modules

Available module directories:

- [Generic](./modules/generic)
- [AWS](./modules/aws)
- [Scaleway](./modules/scaleway)
- [GCP](./modules/google)
- [Azure](./modules/azure)

Contributions adding or completing provider-specific modules are welcome.

## Development

Install the pinned tools with [mise](https://mise.jdx.dev/):

```bash
mise install
```

Install and run pre-commit hooks:

```bash
pre-commit install
pre-commit run -a
```

The hooks run Terraform formatting/validation, generated documentation, Renovate config validation, `zizmor`, and generic file checks. Module documentation is generated with [`terraform-docs`](https://github.com/terraform-docs/terraform-docs) through a small wrapper that excludes `.tofu` override files from docs input.

## Automation

- Renovate manages Terraform, GitHub Actions, pre-commit, mise, and Helm dependency updates.
- Mergify auto-approves and merges Renovate non-major updates after required checks pass.
- GitHub Actions are pinned by commit SHA and scanned by `zizmor`.

## Contributing

Report issues, questions, and feature requests in the [issue tracker](https://github.com/shardlabsxyz/terraform-kubernetes-addons/issues/new).

Full contributing guidelines are covered in [.github/CONTRIBUTING.md](./.github/CONTRIBUTING.md).

## License

This project is licensed under the [MIT License](./LICENSE).
