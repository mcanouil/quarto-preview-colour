# Preview Colour Extension For Quarto

`preview-colour` is a [Quarto](https://quarto.org) extension that automatically renders colour previews for inline colour codes in both inline code blocks and regular text.
It supports multiple colour formats including hex, RGB, HSL, and HWB values.
It supports rendering in various output formats such as HTML, Reveal.js, PDF (via LaTeX), Beamer (LaTeX), Typst, Word, and PowerPoint.

## Installation

You can install this extension using the Quarto CLI:

```bash
quarto add mcanouil/quarto-preview-colour@1.6.0
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
- text: #441100 or rgb(10, 100, 200)
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
- ✅ rgb:
  - ✅ **code**: `rgb(10, 100, 200)`
  - ✅ **code** (no space): `rgb(10,100,200)`
  - ✅ **text**: rgb(10, 100, 200)
  - ✅ **text** (no space): rgb(10,100,200)
- ✅ rgb with %:
  - ✅ **code**: `rgb(100%, 20%, 100%)`
  - ✅ **code** (no space): `rgb(100%,20%,100%)`
  - ✅ **text**: rgb(100%, 20%, 100%)
  - ✅ **text** (no space): rgb(100%,20%,100%)
- ✅ hwb:
  - ✅ **code**: `hwb(135 0% 40%)`
  - ✅ **text**: hwb(135 0% 40%)
- ✅ hsl:
  - ✅ **code**: `hsl(240, 100%, 50%)`
  - ✅ **code** (no space): `hsl(240,100%,50%)`
  - ✅ **text**: hsl(240, 100%, 50%)
  - ✅ **text** (no space): hsl(240,100%,50%)
- ✅ rgba (alpha channel):
  - ✅ **code**: `rgba(255, 0, 0, 0.5)`
  - ✅ **code** (percent alpha): `rgba(255, 0, 0, 50%)`
  - ✅ **text**: rgba(255, 0, 0, 0.5)
- ✅ hsla (alpha channel):
  - ✅ **code**: `hsla(120, 100%, 50%, 0.25)`
  - ✅ **text**: hsla(120, 100%, 50%, 0.25)
- ✅ CSS keywords:
  - ✅ **code**: `currentColor`, `transparent`
  - ✅ **text**: currentColor, transparent

### Alpha and Keyword Format Coverage

| Token form     | HTML | LaTeX | Typst | DOCX | PPTX | Notes                                                              |
| -------------- | ---- | ----- | ----- | ---- | ---- | ------------------------------------------------------------------ |
| `rgba()`       | full | hex   | hex   | hex  | hex  | Non-HTML targets render the opaque colour and warn once.           |
| `hsla()`       | full | hex   | hex   | hex  | hex  | Non-HTML targets render the opaque colour and warn once.           |
| `currentColor` | full | -     | -     | -    | -    | Skipped outside HTML (one-time warning); no opaque equivalent.     |
| `transparent`  | full | -     | -     | -    | -    | Skipped outside HTML (one-time warning); the swatch is invisible.  |

## Bulk JSON Export

The extension can write every detected colour to a JSON file for downstream tooling (audits, palette extraction, design systems).
Enable bulk export via `extensions.preview-colour.json`.
Set the value to `true` to write `preview-colour.json` in the project root, or supply a custom path:

```yaml
extensions:
  preview-colour:
    json: my-colours.json
```

The exported file has the following shape:

```json
{
  "extension": "preview-colour",
  "count": 3,
  "colours": [
    {
      "original": "#FF0000",
      "hex": "#FF0000",
      "css": "#FF0000",
      "source": "code"
    },
    {
      "original": "rgba(255, 0, 0, 0.5)",
      "hex": "#FF0000",
      "alpha": "80",
      "css": "rgba(255, 0, 0, 0.5)",
      "source": "code"
    },
    {
      "original": "currentColor",
      "keyword": "currentColor",
      "css": "currentColor",
      "source": "text"
    }
  ]
}
```

The `source` field reports where the colour was detected:

- `code` for inline-code matches.
- `text` for single-token text matches.
- `text-multitoken` for function-style colours that span several Pandoc Str/Space tokens.

## Performance

The filter scans every `Str` and `Code` inline element in the document.
Cost is linear in the number of inline tokens; documents with thousands of paragraphs may add measurable overhead.
Disable scanning where it is not needed by setting `code: false` or `text: false`.

## Deprecation Timeline

The top-level `preview-colour:` configuration block is **deprecated** since v1.4.0 (2026-02-21) in favour of the namespaced `extensions.preview-colour:` block.
The current behaviour is:

| Version | Behaviour                                                                          |
| ------- | ---------------------------------------------------------------------------------- |
| 1.4.x   | Both forms accepted; first deprecated invocation emits a one-time warning.         |
| 1.5.x   | Both forms accepted; warning unchanged.                                            |
| 1.6.0   | Both forms accepted; warning unchanged. Documentation flagged for removal at v2.0. |
| 2.0.0   | Top-level form removed. Use `extensions.preview-colour:` exclusively.              |

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
