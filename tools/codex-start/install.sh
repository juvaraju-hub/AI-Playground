#!/usr/bin/env bash
set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
target_dir=${CODEX_START_INSTALL_DIR:-"$HOME/bin"}
shell_rc=${CODEX_START_SHELL_RC:-"$HOME/.zshrc"}

mkdir -p "$target_dir"
install -m 0755 "$repo_root/bin/codex-start" "$target_dir/codex-start"

printf 'Installed codex-start to %s/codex-start\n' "$target_dir"

case ":$PATH:" in
  *":$target_dir:"*)
    ;;
  *)
    printf '\n%s is not on PATH in this shell.\n' "$target_dir"
    printf 'Add this line to %s if needed:\n' "$shell_rc"
    printf '  export PATH="%s:$PATH"\n' "$target_dir"
    ;;
esac

printf '\nSuggested aliases:\n'
printf '  alias cx=codex-start\n'
printf '  alias cxc="codex-start --check-only"\n'
