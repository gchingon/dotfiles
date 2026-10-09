#!/usr/bin/env python3
"""Generate a glow wallpaper for each custom theme (theme-switcher/custom/<name>/colors.toml).

Writes ~/Pictures/Wallpapers/<name>_1-glow.png, which `theme`'s apply_wallpaper
picks up by the "<theme>_" prefix. Idempotent, and only fills gaps: a theme that
already has ANY wallpaper (e.g. one you added by hand) is skipped.
Pure stdlib (no PIL). Size: $WALL_W x $WALL_H (default 3024x1964, the 14" MBP).
"""
import math, os, re, struct, sys, zlib

HOME = os.path.expanduser("~")
CUSTOM = os.path.join(HOME, ".config/theme-switcher/custom")
OUT = os.environ.get("WALL_OUT", os.path.join(HOME, "Pictures/Wallpapers"))
W = int(os.environ.get("WALL_W", 3024))
H = int(os.environ.get("WALL_H", 1964))

# which three palette colors become the glow blobs (default: magenta, blue, green)
BLOB_KEYS = {"tokyo-vibe": ("red", "blue", "cyan")}
DEFAULT_KEYS = ("magenta", "blue", "green")


def load_toml(path):
    d = {}
    for line in open(path):
        m = re.match(r'\s*([A-Za-z0-9_]+)\s*=\s*"([^"]*)"', line)
        if m:
            d[m.group(1)] = m.group(2)
    return d


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def chunk(tag, data):
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def make_png(path, bg, colors):
    blobs = [
        (0.72, 0.22, 0.55, colors[0], 0.85),
        (0.22, 0.75, 0.62, colors[1], 0.60),
        (0.85, 0.85, 0.40, colors[2], 0.30),
    ]
    rows = []
    for y in range(H):
        ny = y / H
        row = bytearray([0])
        lift = ny * 0.15
        base = tuple(bg[i] + ((0, 1, 10)[i] - bg[i]) * lift for i in range(3))
        for x in range(W):
            nx = x / W
            px = base
            for bx, by, radius, color, strength in blobs:
                d = math.hypot(nx - bx, (ny - by) * (H / W))
                t = max(0.0, 1.0 - d / radius)
                t = t * t * strength
                if t > 0:
                    px = tuple(min(255, px[i] + color[i] * t * 0.9) for i in range(3))
            row += bytes(max(0, min(255, int(round(c)))) for c in px)
        rows.append(bytes(row))
    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(b"".join(rows), 6))
           + chunk(b"IEND", b""))
    with open(path, "wb") as f:
        f.write(png)


def main():
    if not os.path.isdir(CUSTOM):
        return
    os.makedirs(OUT, exist_ok=True)
    for name in sorted(os.listdir(CUSTOM)):
        toml = os.path.join(CUSTOM, name, "colors.toml")
        dest = os.path.join(OUT, f"{name}_1-glow.png")
        if not os.path.isfile(toml):
            continue
        if any(f.startswith(name + "_") for f in os.listdir(OUT)):
            continue
        pal = load_toml(toml)
        keys = BLOB_KEYS.get(name, DEFAULT_KEYS)
        make_png(dest, rgb(pal["background"]), [rgb(pal[k]) for k in keys])
        print(f"  wallpaper → {dest}")


if __name__ == "__main__":
    sys.exit(main())
