# Preview Colour Extension For Quarto

`preview-colour` is a [Quarto](https://quarto.org) extension that automatically renders colour previews for inline colour codes in both code blocks and regular text. It supports multiple colour formats including hex, RGB, HSL, and HWB values.

## Installation

You can install this extension using the Quarto CLI:

```bash
quarto add mcanouil/quarto-preview-colour
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Usage

### Basic Setup

Add the extension to your document's YAML front matter:

```yaml
filters:
  - preview-colour
```

### Configuration Options

Configure which elements should show colour previews:

```yaml
extensions:
  preview-colour:
    code: true   # Enable previews for inline code
    text: false   # Enable previews for regular text
```

## Supported Colour Formats

- [ ] Names one: `orange` (*will probably never be supported*)
- [x] hex codes:
  - [x] **code**: `#441100`
  - [x] **text**: #441100
- [x] short hex codes:
  - [x] **code**: `#F03`
  - [x] **text**: #F03
- [ ] rgb:
  - [x] **code**: `rgb(10, 100, 200)`
  - [x] **code** (no space): `rgb(10,100,200)`
  - [ ] **text**: rgb(10, 100, 200)
  - [x] **text** (no space): rgb(10,100,200)
- [ ] rgb with %:
  - [x] **code**: `rgb(100%, 20%, 100%)`
  - [x] **code** (no space): `rgb(100%,20%,100%)`
  - [ ] **text**: rgb(100%, 20%, 100%)
  - [x] **text** (no space): rgb(100%,20%,100%)
- [ ] hwb:
  - [x] **code**: `hwb(135 0% 40%)`
  - [ ] **text**: hwb(135 0% 40%)
- [ ] hsl:
  - [x] **code**: `hsl(240, 100%, 50%)`
  - [x] **code** (no space): `hsl(240,100%,50%)`
  - [ ] **text**: hsl(240, 100%, 50%)
  - [x] **text** (no space): hsl(240,100%,50%)

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
