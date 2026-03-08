# Workspace

A VSCode devcontainer scaffold for Python projects with Claude Code AI-assisted development.

## Structure

```
workspace/
├── .devcontainer/        # VSCode devcontainer configuration
│   ├── devcontainer.json
│   ├── Dockerfile
│   ├── init-docker.sh
│   └── init-firewall.sh
└── repos/                # Clone your Python projects here
```

## Devcontainer

The devcontainer (`devcontainer.json` + `Dockerfile`) provides:

- **Base**: Node.js 20
- **Shell**: zsh with fzf, git plugins
- **Python**: 3.12 via pyenv
- **Tools**: Claude Code CLI, Docker-in-Docker, GitHub CLI (`gh`), git-delta, jq, vim, nano
- **VSCode extensions**: Claude Code, ESLint, Prettier, GitLens
- **Networking**: `NET_ADMIN`/`NET_RAW` capabilities for optional firewall init

The `node` user's home directory and command history are persisted in named Docker volumes across rebuilds. The SSH agent socket is forwarded from the host.

## Adding a Python Project

`workspace.code-workspace` is gitignored — create your own by copying the template:

```bash
cp workspace.code-workspace.template workspace.code-workspace
```

Then clone your repo and add it to the workspace:

1. Clone into `repos/`:
   ```bash
   git clone <repo-url> repos/<name>
   ```
2. Add it to the workspace via **File > Add Folder to Workspace...** or manually add an entry to `workspace.code-workspace`:
   ```json
   { "name": "<name>", "path": "repos/<name>" }
   ```
