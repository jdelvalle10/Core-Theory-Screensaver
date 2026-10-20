# Core Theory — classroom display

A 40-second looping animation of the Core Theory equation (after S. Carroll & F. Wilczek):
assembly → glow sequence with bilingual captions → 5 s hold → one rotating "what's missing" beat → particle dissolve.

## Install (Ubuntu 24.04, Firefox)

1. Copy this folder to the smartboard PC (USB drive or download).
2. Open a terminal in the folder and run:

       bash install.sh

   Use `bash install.sh --no-dock` if you don't want the icon added to the dock.
3. Start it from the dock, the app grid (search "Core Theory"), or the desktop icon.
   If the desktop icon shows a lock or won't launch, right-click it → **Allow Launching**.

Touch the board or press any key to exit. Input is ignored for the first 1.5 s so the tap
that starts it doesn't close it.

## Remove

    bash uninstall.sh

## Preview on any computer

Open `core-theory.html` in a browser. Optional URL parameters:

| Parameter | Effect |
|---|---|
| `?t=31` | Freeze at second 31 (0–40) |
| `?egg=0` … `?egg=3` | Force an Easter egg (dark matter, dark energy, neutrino mass, cutoff) |
| `?fxw=1280` | Lower the effects resolution if animation stutters (default 1920) |

## What the installer does

- Copies the page into `~/snap/firefox/common/core-theory` (snap Firefox) or `~/.local/share/core-theory`.
- Creates a separate, quiet Firefox profile there; your normal Firefox profile is untouched.
- Launches Firefox in kiosk mode and keeps the screen from blanking while it plays.
- No sudo, no internet needed: KaTeX and all fonts are embedded in the HTML file.

## Building from source

`core-theory.html` is generated: it inlines KaTeX (JavaScript, CSS and fonts) into `src/app.html`.

    npm install
    python3 build.py

Edit `src/app.html`, then rebuild. Captions, labels and Easter egg text are at the top of its script.

## Credits

Equation after Sean Carroll's presentation of Frank Wilczek's "Core Theory".
Math rendering by [KaTeX](https://katex.org) (MIT License).
