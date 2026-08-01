# Preview Colour Extension For Quarto

`preview-colour` is a [Quarto](https://quarto.org) extension that draws a coloured swatch beside every colour code in a document, in inline code and in ordinary prose.

It recognises named colours, hex, `rgb()`, `rgba()`, `hsl()`, `hsla()`, `hwb()`, and the CSS keywords, and renders in HTML, Reveal.js, LaTeX, Beamer, Typst, Word, and PowerPoint.

## Installation

You can install this extension using the Quarto CLI:

```bash
quarto add mcanouil/quarto-preview-colour@1.6.0
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Documentation

The full documentation lives at <https://m.canouil.dev/quarto-preview-colour/>: every colour format, the glyph options, per-format coverage of transparency, the JSON export, and swatches you can see.

[`example.qmd`](example.qmd) is a short, standalone starting point you can copy, rendered to every supported format and attached to each release.

## Licence

[MIT](https://github.com/mcanouil/quarto-preview-colour?tab=MIT-1-ov-file#readme).
