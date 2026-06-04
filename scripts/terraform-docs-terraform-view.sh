#!/usr/bin/env bash
set -euo pipefail

if ! command -v terraform-docs >/dev/null 2>&1; then
  echo "terraform-docs is required but was not found in PATH" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
config_file="${repo_root}/.terraform-docs.yml"

declare -A module_dirs=()
for file in "$@"; do
  [[ -e "${file}" ]] || continue
  module_dirs["$(dirname "${file}")"]=1
done

for module_dir in "${!module_dirs[@]}"; do
  abs_module_dir="${repo_root}/${module_dir}"
  readme_file="${abs_module_dir}/README.md"

  [[ -f "${readme_file}" ]] || continue
  grep -q '<!-- BEGIN_TF_DOCS -->' "${readme_file}" || continue

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "${tmp_dir}"' EXIT

  cp -RL "${abs_module_dir}/." "${tmp_dir}/"
  # terraform-docs does not apply OpenTofu .tofu override semantics.
  find "${tmp_dir}" -name '*.tofu' -type f -delete

  terraform-docs \
    --config="${config_file}" \
    --output-mode=inject \
    --output-file="${readme_file}" \
    "${tmp_dir}" >/dev/null

  rm -rf "${tmp_dir}"
  trap - EXIT
done
