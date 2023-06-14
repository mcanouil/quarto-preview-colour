# Preview Colour Extension For Quarto

`preview-colour` is an extension for [Quarto](https://quarto.org) to provide access to LUA objects as metadata.

## Installing

```bash
quarto add mcanouil/quarto-preview-colour
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

Add the following to your YAML header:

```yaml
filters:
  - preview-colour
```

Then define the following metadata to enable the extension for inline code and text:

```yaml
preview-colour:
  code: true
  text: true
```

## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).
