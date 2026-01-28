# Preview Colour Extension For Quarto

`preview-colour` is a [Quarto](https://quarto.org) extension that automatically renders colour previews for inline colour codes in both inline code blocks and regular text.
It supports multiple colour formats including hex, RGB, HSL, and HWB values.
It supports rendering in various output formats such as HTML, Reveal.js, PDF (via LaTeX), Beamer (LaTeX), Typst, Word, and PowerPoint.

## Installation

You can install this extension using the Quarto CLI:

```bash
quarto add mcanouil/quarto-preview-colour
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Usage

### Basic Setup

To activate the filter, add the following to your YAML front matter:

- Old (<1.8.21):

  ```yml
  filters:
    - quarto
    - preview-colour
  ```

- New (>=1.8.21):

  ```yml
  filters:
    - path: preview-colour
      at: post-quarto
  ```

```qmd
- code: `#441100` or `rgb(10, 100, 200)`
- text: #441100 or rgb(10,100,200)
```

> [!NOTE]
> Colour codes should be placed in inline code blocks (alone) or regular text.
>
> ❌ Invalid:
>
> - `` `"My colour is #441100"` ``
> - `` `["#441100", "#114400"]` ``
>
> ✅ Valid:
>
> - `` `#441100` ``

### Configuration Options

Configure which elements should show colour previews:

```yaml
extensions:
  preview-colour:
    code: true # Enable previews for inline code
    text: false # Enable previews for regular text
```

### Custom Glyph

Customise the glyph symbol used for colour previews:

```yaml
# Simple: single glyph for all formats
extensions:
  preview-colour:
    glyph: "●"

# Advanced: per-format glyphs
extensions:
  preview-colour:
    glyph:
      default: "●"
      html: "&#9632;"
      latex: '\\textbullet' # Important: Single quotes and LaTeX escape
      typst: "◆"
      docx: "◉"
      pptx: "◉"
```

Default glyphs when not customised:

| Format | Glyph         | Description             |
| ------ | ------------- | ----------------------- |
| HTML   | `&#9673;`     | Fisheye (hollow circle) |
| LaTeX  | `\textbullet` | Bullet point            |
| Typst  | `◉`           | Fisheye                 |
| DOCX   | `●`           | Black circle            |
| PPTX   | `●`           | Black circle            |

## Supported Colour Formats

- ✅ Named colours (CSS Level 4):
  - ✅ **code**: `red`, `rebeccapurple`, `cornflowerblue`
  - ✅ **text**: red, rebeccapurple, cornflowerblue
  - ✅ Supports 140+ CSS named colours including British/American variants (`gray`/`grey`)
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

Output of `example.qmd`:

- [HTML](https://m.canouil.dev/quarto-preview-colour/)
- [Typst/PDF](https://m.canouil.dev/quarto-preview-colour/preview-colour-typst.pdf)
- [LaTeX/PDF (XeLaTeX)](https://m.canouil.dev/quarto-preview-colour/preview-colour-xelatex.pdf)
- [LaTeX/PDF (LuaLaTeX)](https://m.canouil.dev/quarto-preview-colour/preview-colour-lualatex.pdf)
- [LaTeX/PDF (PDFLaTeX)](https://m.canouil.dev/quarto-preview-colour/preview-colour-pdflatex.pdf)
- [Reveal.js](https://m.canouil.dev/quarto-preview-colour/preview-colour-revealjs.html)
- [Beamer/PDF](https://m.canouil.dev/quarto-preview-colour/preview-colour-beamer.pdf)
- [Word/Docx](https://m.canouil.dev/quarto-preview-colour/preview-colour-docx.docx)
- [PowerPoint/Pptx](https://m.canouil.dev/quarto-preview-colour/preview-colour-pptx.pptx)
