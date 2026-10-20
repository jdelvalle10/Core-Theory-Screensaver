#!/usr/bin/env python3
"""Inline KaTeX (JS, CSS, woff2 fonts) into a single self-contained core-theory.html."""
import base64, re, pathlib, sys

root = pathlib.Path(__file__).parent
kdir = root / "node_modules" / "katex" / "dist"
css = (kdir / "katex.min.css").read_text()

def font_src(m):
    name = m.group(1)
    data = base64.b64encode((kdir / "fonts" / f"{name}.woff2").read_bytes()).decode()
    return f'src:url(data:font/woff2;base64,{data}) format("woff2")'

# Replace each @font-face src list with a single embedded woff2.
css, n = re.subn(r'src:url\(fonts/([A-Za-z0-9_\-]+)\.woff2\) format\("woff2"\)[^;}]*', font_src, css)
assert n >= 15, f"only {n} font sources replaced"
js = (kdir / "katex.min.js").read_text()
assert "</script" not in js

app = (root / "src" / "app.html").read_text()
app = app.replace("/*__KATEX_CSS__*/", css, 1).replace("/*__KATEX_JS__*/", js, 1)
out = root / "core-theory.html"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(app)
print(out, f"{out.stat().st_size/1024:.0f} KB, {n} fonts embedded")
