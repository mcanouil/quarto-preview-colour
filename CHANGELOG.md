# Changelog

## Unreleased

## 1.6.0 (2026-05-28)

### Bug Fixes

- fix: Repair the HSL inline pattern so values such as `hsl(240, 100%, 50% )` and `hsl(240, 100%, 50%)` are detected; previously a stray literal in the regex (`%%s*` instead of `%%%s*`, plus a missing `%s*` before the second comma) rejected any whitespace before the closing parenthesis or before the comma after the second percentage.
- fix: Preserve trailing punctuation when a multi-token colour ends a sentence; `rgb(255, 0, 0).` and `hsla(120, 100%, 50%, 0.25).` in plain text are now detected, then the trailing punctuation is reinserted unchanged.

### New Features

- feat: Add alpha-channel support for `rgba()` and `hsla()` in both inline code and plain text. HTML renders the alpha-bearing colour faithfully, while LaTeX, Typst, DOCX, and PPTX render the opaque hex and emit a one-time warning.
- feat: Recognise the CSS keyword colours `currentColor` and `transparent`. HTML renders the swatch with `color: currentColor` or `color: transparent`; other formats skip the swatch with a one-time warning.
- feat: Add bulk JSON export of detected colours via `extensions.preview-colour.json` (mirroring the `lua-env` JSON feature). Set to `true` to write `preview-colour.json`, or supply a file path. Each entry records the original token, hex (when available), alpha, keyword, css, and the source (`code`, `text`, or `text-multitoken`).

### Documentation

- docs: Document alpha, keyword, and JSON-export features in `README` and `example.qmd`.
- docs: Add a performance note (the filter scans every `Str` element; cost is linear in document size).
- docs: Add a deprecation timeline for the legacy top-level `preview-colour:` configuration; removal is planned for v2.0.0.

### Schema and Snippets

- feat: Add `json` to `_schema.yml` so editors can validate and autocomplete the bulk-export option.
- feat: Add a `preview-colour-json` snippet to `_snippets.json`.

## 1.5.1 (2026-04-15)

### Refactoring

- refactor: Synchronise shared module (`logging.lua`) with canonical version.

## 1.5.0 (2026-03-23)

### Refactoring

- refactor: Replace monolithic `utils.lua` with focused modules (`string.lua`, `logging.lua`, `metadata.lua`, `pandoc-helpers.lua`, `html.lua`, `paths.lua`, `colour.lua`).

## 1.4.0 (2026-02-21)

### New Features

- feat: Add extension-provided code snippets (#47).
- feat: Add _schema.yml for configuration validation and IDE support (#44).

## 1.3.1 (2026-02-11)

## 1.3.0 (2026-01-28)

### New Features

- feat: Support text mode colours with spaces (#40).
- feat: Add CSS named colour support (#39).
- feat: Add customisable glyph for colour preview (#38).
- feat: Support multiple colours inline and embedded colours (#37).

### Bug Fixes

- fix: Update copyright year.
- fix: Use british english spelling.

### Documentation

- docs: Remove duplicated sentence in README.

## 1.1.0 (2025-10-25)

### Refactoring

- refactor: Use module and enhance extension (#35).

### Documentation

- docs: Revise filter setup instructions.

## 1.0.4 (2025-10-16)

### Documentation

- docs: Use the complete filter declaration.

## 1.0.3 (2025-07-22)

### Bug Fixes

- fix: Wrong number of dashes in luadocs.

### Refactoring

- refactor: Use type luadocs.
- refactor: Improve format, colour, and escape handling (#31).
- refactor: Enhance filter logic and documentation (#30).

## 1.0.2 (2025-07-21)

### Bug Fixes

- fix: No colour mark on "partial matches" (#27).

### Documentation

- docs: Add note about colour codes not "alone".

## 1.0.1 (2025-07-21)

### Bug Fixes

- fix: Prevent colour preview for multiple matches (#25).
- fix: Incorrect URLs to live examples.

## 1.0.0 (2025-07-19)

### New Features

- feat: Add support for DOCX and PPTX formats (#21).
- feat: Make glyph clickable to copy colour code (#20).
- feat: Enhance HTML colour mark with title and aria-label (#19).
- feat: Add Typst support for colour previews (#18).
- feat: Support inline colour codes in text (#16).
- feat: Add HWB colour support (#15).
- feat: Support RGB with percentages in colour conversion (#14).
- feat: Add CITATION file for project citation.

### Bug Fixes

- fix: Set YAML under "extensions" meta.
- fix: Improve RGB support and colour blending (#11).
- fix: Engine markdown.
- fix: Render all formats and link them.
- fix: Switch to deploy from GitHub Actions (#10).

### Refactoring

- refactor: Use format helper functions.
- refactor: Scope configuration under "extensions" (#17).

### Documentation

- docs: Add rendering formats.
- docs: Add type hints and documentation.

## 0.3.0 (2023-08-27)

### New Features

- feat: Add support for rgb/hsl inline code.

### Refactoring

- refactor: Remove unused code and improve code to parse everywhere (#6).

## 0.2.0 (2023-06-15)

### New Features

- feat: Support latex.

## 0.1.0 (2023-06-14)

