# Preview Colour Extension For Quarto

`preview-colour` is a [Quarto](https://quarto.org) extension that automatically renders colour previews for inline colour codes in both code blocks and regular text.
It supports multiple colour formats including hex, RGB, HSL, and HWB values.

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

````qmd
- code: `#441100` or `rgb(10, 100, 200)`
- text: #441100 or rgb(10,100,200)
````

### Configuration Options

Configure which elements should show colour previews:

```yaml
extensions:
  preview-colour:
    code: true   # Enable previews for inline code
    text: false   # Enable previews for regular text
```

## Supported Colour Formats

- ❌ Names one: `orange` (*will probably never be supported*)
- ✅ hex codes:
  - ✅ **code**: `#441100`
  - ✅ **text**: #441100
- ✅ short hex codes:
  - ✅ **code**: `#F03`
  - ✅ **text**: #F03
- 🔶 rgb:
  - ✅ **code**: `rgb(10, 100, 200)`
  - ✅ **code** (no space): `rgb(10,100,200)`
  - ❌ **text**: rgb(10, 100, 200)
  - ✅ **text** (no space): rgb(10,100,200)
- 🔶 rgb with %:
  - ✅ **code**: `rgb(100%, 20%, 100%)`
  - ✅ **code** (no space): `rgb(100%,20%,100%)`
  - ❌ **text**: rgb(100%, 20%, 100%)
  - ✅ **text** (no space): rgb(100%,20%,100%)
- 🔶 hwb:
  - ✅ **code**: `hwb(135 0% 40%)`
  - ❌ **text**: hwb(135 0% 40%)
- 🔶 hsl:
  - ✅ **code**: `hsl(240, 100%, 50%)`
  - ✅ **code** (no space): `hsl(240,100%,50%)`
  - ❌ **text**: hsl(240, 100%, 50%)
  - ✅ **text** (no space): hsl(240,100%,50%)

## Examples

Here is the source code for a minimal example: [`example.qmd`](example.qmd).

Outputs of `example.qmd`:

- [HTML](https://m.canouil.dev/quarto-preview-colour-text/)
- [Typst/PDF](https://m.canouil.dev/quarto-preview-colour-text/preview-colour-typst.pdf)
- [LaTeX/PDF (XeLaTeX)](https://m.canouil.dev/quarto-preview-colour-text/preview-colour-xelatex.pdf)
- [LaTeX/PDF (LuaLaTeX)](https://m.canouil.dev/quarto-preview-colour-text/preview-colour-lualatex.pdf)
- [LaTeX/PDF (PDFLaTeX)](https://m.canouil.dev/quarto-preview-colour-text/preview-colour-pdflatex.pdf)
- [Reveal.js](https://m.canouil.dev/quarto-preview-colour-text/preview-colour-revealjs.html)
- [Beamer/PDF](https://m.canouil.dev/quarto-preview-colour-text/preview-colour-beamer.pdf)
- [Word/Docx](https://m.canouil.dev/quarto-highlight-text/highlight-openxml.docx)
- [PowerPoint/Pptx](https://m.canouil.dev/quarto-highlight-text/highlight-pptx.pptx)
