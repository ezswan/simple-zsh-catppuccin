# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] — 2026-06-28

First release of Simple ZSH Catppuccin. Versioning restarts at 1.0.0
(the inherited Dracula `v1.2.5` header was reset).

### Added

- `CATPPUCCIN_DIR_TRIM` option to limit how many trailing directories are shown
  in full-path mode (port of Dracula's `DRACULA_DIR_TRIM`).
- Graceful degradation: if `lib/async.zsh` cannot be found, the git segment
  disables itself with a warning instead of erroring on every prompt.
- `lib/LICENSE` and dual copyright notices so the vendored zsh-async library and
  the upstream Dracula theme are properly attributed.

### Changed

- Recolored the Dracula zsh theme to the Catppuccin Mocha palette.
- Vendored zsh-async updated to v1.8.6.
- Async loader now searches multiple paths and resolves the theme directory
  reliably regardless of how the theme is sourced.

### Fixed

- Arrow icons beginning with `-` are no longer misparsed as flags
  (`print -P -- "$ICON"`).
- The git segment honours a `cd` alias by using `builtin cd`.
- Restored the `DEBUG_OVERRIDE_V` git-version test hook (a duplicated
  `local git_version` had silently overridden it).

[Unreleased]: https://github.com/ezswan/simple-zsh-catppuccin/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ezswan/simple-zsh-catppuccin/releases/tag/v1.0.0
