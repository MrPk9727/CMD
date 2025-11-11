# MVM — VPS helper / installer

This repository contains a simple menu-driven launcher `main.sh` (MVM — Powered by MrPk) that lets you run helper scripts locally or fetch them from the repository raw URL via curl.

Quick start (run on a fresh Ubuntu VPS):

```bash
# Run the launcher directly from GitHub (pipe to bash)
curl -fsSL https://raw.githubusercontent.com/MrPk9727/CMD/main/main.sh | bash
```

Notes:
- `main.sh` prefers local scripts under `Script/mvm/` if present. Otherwise it will curl the script from the repo raw URL (default `https://raw.githubusercontent.com/MrPk9727/CMD/main`).
- Options 1–12 are placeholders. Replace the `Script/mvm/option*.sh` scripts with full implementations (idempotent, well-tested).
- For production use, review each script before running with root privileges. The repo will be expanded to include full installers (pterodactyl panel, wings, docker, etc.).

License: MIT (add `LICENSE` file if you prefer a different license)
