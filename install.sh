#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="${PACKAGE_FILE:-${SCRIPT_DIR}/packages/ubuntu.txt}"
DRY_RUN=false
UPDATE=false

usage() {
  cat <<USAGE
Usage: $0 [--package-file FILE] [--dry-run] [--update]

Options:
  --package-file FILE  Package list (one package per line)
  --dry-run            Show packages without installing them
  --update             Refresh apt package indexes before installation
  -h, --help           Show this help
USAGE
}

log() { printf '[INFO] %s\n' "$*"; }
error() { printf '[ERROR] %s\n' "$*" >&2; }

while (($#)); do
  case "$1" in
    --package-file)
      [[ $# -ge 2 ]] || { error "--package-file requires a value"; exit 2; }
      PACKAGE_FILE="$2"
      shift 2
      ;;
    --dry-run) DRY_RUN=true; shift ;;
    --update) UPDATE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) error "Unknown option: $1"; usage >&2; exit 2 ;;
  esac
done

[[ -f "$PACKAGE_FILE" ]] || { error "Package file not found: $PACKAGE_FILE"; exit 1; }

mapfile -t PACKAGES < <(sed 's/#.*//' "$PACKAGE_FILE" | awk 'NF {print $1}')
((${#PACKAGES[@]} > 0)) || { error "No packages found in $PACKAGE_FILE"; exit 1; }

if $DRY_RUN; then
  log "Dry run; no packages will be installed."
  printf '  %s\n' "${PACKAGES[@]}"
  exit 0
fi

command -v apt-get >/dev/null 2>&1 || { error "apt-get is required for this installer"; exit 1; }

APT=(apt-get)
if [[ $EUID -ne 0 ]]; then
  command -v sudo >/dev/null 2>&1 || { error "sudo is required when not running as root"; exit 1; }
  APT=(sudo apt-get)
fi

if $UPDATE; then
  log "Refreshing package indexes..."
  "${APT[@]}" update
fi

log "Installing ${#PACKAGES[@]} package(s)..."
"${APT[@]}" install -y "${PACKAGES[@]}"
log "Package installation completed."
