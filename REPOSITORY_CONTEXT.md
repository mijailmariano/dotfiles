# Repository Context

## Purpose and scope

This public, macOS-oriented repository owns shared machine-bootstrap
configuration and portable user and tool configuration. It supports rebuilding
a machine and maintaining shared configuration through the checkout, whose
documented installation location is `~/.dotfiles`.

Project-specific configuration and project-local automation belong in the
relevant project. Reusable cross-project AI and project automation belongs in
the separately maintained `~/code/workbench` where the repository establishes
that integration. This document makes no architecture support commitment beyond
the behavior present in the repository.

## Ownership map

- `Brewfile` is the package declaration used by the Homebrew bundle step.
- `configs/` is the source for shared configuration deployed into the home
  directory.
- `scripts/setup.sh` defines machine bootstrap, backup, package installation,
  and symlink behavior.
- `scripts/init-direnv.sh` defines project `.envrc` generation and its direnv
  allow flow.
- `README.md` owns operator-oriented bootstrap and usage workflows.
- `.github/` owns repository-platform metadata and supplemental, scoped tool
  guidance; scripts and configuration remain authoritative for behavior.

## Deployment and symlink model

The supported checkout location is `~/.dotfiles`. At setup time,
`scripts/setup.sh` creates a timestamped directory under `~/.backupConfigs/`
and backs up existing managed configuration before replacing destinations with
links to sources under `configs/`.

Root home dotfiles are explicitly registered in the `items` array in
`scripts/setup.sh`. Adding one requires both its source under `configs/` and a
new array entry. By contrast, immediate child directories under
`configs/.config/` are discovered automatically and linked to matching paths
under `~/.config/`; a new directory there normally needs no separate
registration.

Because deployment uses symlinks, editing a live linked path can modify the
tracked source in this checkout. Consult `scripts/setup.sh` for exact behavior.

## Shared versus machine-local configuration

Committed configuration under `configs/` is shared. Keep machine-specific
values local when a component has an established override pattern. WezTerm is
the current example:

- Shared: `configs/.config/wezterm/wezterm.lua`
- Local and ignored: `configs/.config/wezterm/wezterm.local.lua`

The shared WezTerm configuration conditionally loads that local override.
`.gitignore` is authoritative for currently excluded local or generated state;
do not assume other applications support the same override mechanism.

## Modification rules

- Inspect the relevant source and deployment behavior before changing
  configuration, and preserve the ownership boundaries above.
- Extend existing repository patterns instead of adding parallel deployment or
  configuration mechanisms.
- Do not edit generated or tool-managed files unless repository evidence
  establishes their update mechanism. Do not infer ownership for unresolved
  backup, lock, generated, or historical artifacts.
- Preserve the backup behavior in `scripts/setup.sh`; do not bypass or weaken
  it.
- Treat `Brewfile` as the package declaration source of truth. Pulling an
  updated file does not install its contents; package installation occurs only
  when the relevant Homebrew bundle command is run.
- Keep changes scoped and avoid unrelated cleanup.

## Public repository and security boundary

This repository is public. Do not commit credentials, tokens, private keys,
secrets, sensitive environment values, or private machine-generated state.
`.env` is currently ignored, but `.gitignore` is not a substitute for reviewing
the complete change before committing it.

## Validation expectations

Validate only the area changed. Applicable non-installing checks include:

```bash
git diff --check
bash -n scripts/setup.sh
bash -n scripts/init-direnv.sh
zsh -n configs/.zshrc
brew bundle check --file=Brewfile
wezterm --config-file ~/.config/wezterm/wezterm.lua show-keys --lua >/dev/null
```

Use the shell syntax checks only for the corresponding script or shell-config
change. `brew bundle check` checks whether the current machine satisfies
`Brewfile`; it is not a general repository test suite. The WezTerm check assumes
WezTerm is installed and the documented symlink has been deployed. The
repository currently has no general CI or automated test suite, so do not
invent a universal test command.

## Authoritative sources and progressive disclosure

Use this routing model:

1. Read `REPOSITORY_CONTEXT.md` for repository-level invariants.
2. Read `README.md` for operator workflows and usage.
3. Inspect the relevant script or configuration for exact current behavior.
4. Load only the component needed for the requested change in detail.

Scripts and configuration are authoritative for current behavior. If
documentation conflicts with implementation, report the discrepancy rather
than silently normalizing it.
