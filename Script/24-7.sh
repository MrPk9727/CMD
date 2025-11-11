#!/usr/bin/env bash
set -euo pipefail

# Minimal 24-7 installer/launcher
# Prints only two lines as requested, installs python, then runs the python script.

SCRIPT_PY="Script/24-7.py"

echo "installing python"

# Install quietly (suppress apt/pip output). Errors will still stop the script.
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y >/dev/null 2>&1
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip >/dev/null 2>&1
  sudo python3 -m pip install --upgrade pip setuptools wheel >/dev/null 2>&1
else
  # Non-apt systems: attempt to install pip via get-pip or assume python3 exists
  true
fi

echo "running it"

# Execute the python script (replace the shell with the python process)
exec python3 "$SCRIPT_PY"

--dry-run   Print actions instead of executing them.
--venv DIR  Create a virtualenv at DIR and install requirements into it (requires python3-venv).
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --venv) VENV_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 2 ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "+ $*"
  else
    echo "=> Running: $*"
    eval "$@"
  fi
}

detect_apt() {
  if command -v apt-get >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

if ! detect_apt; then
  echo "This installer currently supports Debian/Ubuntu (apt). Exiting." >&2
  exit 1
fi

echo "24-7 installer: will install python3, pip and requirements (dry-run=$DRY_RUN)"

PKGS=(python3 python3-venv python3-pip build-essential)

if [ "$DRY_RUN" -eq 0 ]; then
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PKGS[@]}"
  sudo python3 -m pip install --upgrade pip setuptools wheel
else
  echo "+ sudo apt-get update -y"
  echo "+ sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ${PKGS[*]}"
  echo "+ sudo python3 -m pip install --upgrade pip setuptools wheel"
fi

# Decide requirements file
REQ_CANDIDATES=("Script/24-7-requirements.txt" "Script/requirements.txt" "requirements.txt")
REQ_FILE=""
for f in "${REQ_CANDIDATES[@]}"; do
  if [ -f "$f" ]; then
    REQ_FILE="$f"
    break
  fi
done

if [ -n "$VENV_DIR" ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "+ python3 -m venv $VENV_DIR"
  else
    python3 -m venv "$VENV_DIR"
    # activate and upgrade pip inside venv
    # shellcheck disable=SC1090
    . "$VENV_DIR/bin/activate"
    pip install --upgrade pip
  fi
fi

if [ -n "$REQ_FILE" ]; then
  echo "Installing requirements from: $REQ_FILE"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "+ python3 -m pip install -r $REQ_FILE"
  else
    if [ -n "$VENV_DIR" ]; then
      # venv active above
      pip install -r "$REQ_FILE"
    else
      sudo python3 -m pip install -r "$REQ_FILE"
    fi
  fi
else
  echo "No requirements file found in Script/ or repo root. Nothing to pip-install." >&2
fi

echo "Done."
