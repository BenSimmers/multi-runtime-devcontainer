# Multi Runtime Development Environment — Bun, Node & Deno

A dev container providing Bun, Node.js (LTS), and Deno out of the box, with a curated set of VS Code extensions for web development.

## Prerequisites

- [Docker](https://www.docker.com/get-started)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

## Getting Started

1. Clone this repository.
2. Open the folder in VS Code.
3. When prompted, select **Reopen in Container** (or run the `Dev Containers: Reopen in Container` or `Dev Containers: Rebuild and Reopen Container without cache` command).

The container is based on `mcr.microsoft.com/devcontainers/base:noble` and installs the following runtimes via dev container features:

| Runtime | Feature |
|---------|---------|
| Node.js (LTS) | `ghcr.io/devcontainers/features/node` |
| Deno | `ghcr.io/devcontainers-community/features/deno` |
| Bun | `ghcr.io/devcontainers-extra/features/bun` |

## Included VS Code Extensions

- ESLint, Prettier, Stylelint
- EditorConfig, Path IntelliSense
- Code Spell Checker
- Python, Docker, GitLens
- Live Server, Markdown All in One
- JavaScript Snippets, HTML Snippets
- Deno, Bun

