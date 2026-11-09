# /// script
# requires-python = ">=3.13"
# dependencies = ["playwright"]
# ///
"""Check the contrast of the copy tooltip for a mark inside inline code.

A theme can colour every `code span` under a colour-scheme scope, such as
`body.quarto-light code span`, and the tooltip is a span inside the code
element. The fixture page adds such rules to a light and a dark theme. The
check clicks the mark, and asserts that the tooltip text has
a contrast of at least 4.5 with its background in each colour scheme. It also
asserts that the glyph keeps its own colour and that the focus ring takes the
colour of the code text.

Run from the repository root:

    CHROME_PATH=/path/to/chromium uv run tests/tooltip-contrast.py

`CHROME_PATH` is optional; without it, Playwright uses its own Chromium.
"""

import functools
import http.server
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

from playwright.sync_api import Page, sync_playwright

ROOT = Path(__file__).resolve().parent.parent
MIN_CONTRAST = 4.5
GLYPH_COLOUR = "rgb(204, 51, 102)"

FIXTURE = """---
title: "Tooltip contrast"
filters:
  - preview-colour
format:
  html:
    theme:
      light: cosmo
      dark: darkly
    include-in-header:
      text: |
        <style>
        body.quarto-light code span { color: #003b4f; }
        body.quarto-dark code span { color: #f8f8f2; }
        </style>
---

A mark inside inline code: `#cc3366`.
"""

SCENARIOS = [
    ("light", "light", None),
    ("dark", "light", "alternate"),
    ("OS dark, page forced light", "dark", "default"),
]


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    """Serve files without a log line for each request."""

    def log_message(self, format: str, *args: object) -> None:
        """Discard the request log."""


def render_fixture(directory: Path) -> Path:
    """Render the fixture page with the extension from this repository.

    Args:
        directory: Empty directory that receives the extension and the page.

    Returns:
        The path of the rendered HTML page.
    """
    shutil.copytree(ROOT / "_extensions", directory / "_extensions")
    source = directory / "index.qmd"
    source.write_text(FIXTURE, encoding="utf-8")
    subprocess.run(["quarto", "render", str(source)], check=True, cwd=directory)
    return directory / "index.html"


def luminance(colour: str) -> float:
    """Compute the WCAG relative luminance of a computed CSS colour.

    Args:
        colour: Colour as `getComputedStyle` gives it, `rgb()` or `rgba()`.

    Returns:
        The relative luminance, from 0 to 1.
    """
    channels = [int(value) / 255 for value in re.findall(r"\d+", colour)[:3]]
    linear = [
        c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in channels
    ]
    return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]


def contrast(foreground: str, background: str) -> float:
    """Compute the WCAG contrast ratio of two computed CSS colours.

    Args:
        foreground: Text colour.
        background: Background colour.

    Returns:
        The contrast ratio, from 1 to 21.
    """
    lighter, darker = sorted(
        (luminance(foreground), luminance(background)), reverse=True
    )
    return (lighter + 0.05) / (darker + 0.05)


def check_scenario(page: Page, url: str, scheme: str | None) -> list[str]:
    """Load the page in one colour scheme, click the mark, and check its colours.

    Args:
        page: Browser page, already set to the OS colour scheme.
        url: Address of the rendered fixture.
        scheme: Value for the `quarto-color-scheme` key, or None to leave it unset.

    Returns:
        One message for each failed check; empty when all checks pass.
    """
    page.goto(url)
    page.evaluate("localStorage.clear()")
    if scheme is not None:
        page.evaluate(f"localStorage.setItem('quarto-color-scheme', '{scheme}')")
    page.reload()
    mark = page.locator("code button.preview-colour")
    mark.click()
    colours = mark.evaluate(
        """(mark) => {
          const tooltip = mark.querySelector('.preview-colour-tooltip');
          const glyph = mark.querySelector('span[style]');
          const style = (element) => getComputedStyle(element);
          return {
            body: document.body.className,
            text: style(tooltip).color,
            background: style(tooltip).backgroundColor,
            glyph: style(glyph).color,
            ring: style(mark).outlineColor,
            code: style(mark.parentElement).color,
          };
        }"""
    )
    failures = []
    ratio = contrast(colours["text"], colours["background"])
    print(f"  body: {colours['body']}")
    print(
        f"  tooltip: {colours['text']} on {colours['background']}, contrast {ratio:.2f}"
    )
    if ratio < MIN_CONTRAST:
        failures.append(f"tooltip contrast {ratio:.2f} is below {MIN_CONTRAST}")
    if colours["glyph"] != GLYPH_COLOUR:
        failures.append(f"glyph colour {colours['glyph']} is not {GLYPH_COLOUR}")
    if colours["ring"] != colours["code"]:
        failures.append(
            f"focus ring {colours['ring']} is not the code colour {colours['code']}"
        )
    return failures


def main() -> int:
    """Run every scenario and report the failed checks.

    Returns:
        The exit status: 0 when every check passes, 1 otherwise.
    """
    failures = []
    with tempfile.TemporaryDirectory() as temporary:
        directory = Path(temporary)
        render_fixture(directory)
        handler = functools.partial(QuietHandler, directory=str(directory))
        server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        url = f"http://127.0.0.1:{server.server_port}/index.html"
        try:
            with sync_playwright() as playwright:
                browser = playwright.chromium.launch(
                    executable_path=os.environ.get("CHROME_PATH")
                )
                for name, os_scheme, page_scheme in SCENARIOS:
                    print(f"{name}:")
                    context = browser.new_context(color_scheme=os_scheme)
                    context.grant_permissions(["clipboard-read", "clipboard-write"])
                    page = context.new_page()
                    failures += [
                        f"{name}: {f}" for f in check_scenario(page, url, page_scheme)
                    ]
                    context.close()
                browser.close()
        finally:
            server.shutdown()
    for failure in failures:
        print(f"FAIL {failure}", file=sys.stderr)
    if not failures:
        print("PASS all scenarios")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
