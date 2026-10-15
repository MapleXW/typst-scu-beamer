#!/usr/bin/env python3
"""Regenerate the README preview images for SCU Beamer for Typst.

Usage (from the repository root):

    python tools/make-preview.py

It needs

  * ``typst`` on PATH (or pass --typst /path/to/typst),
  * Pillow,
  * an SCU-red source colour and the fonts listed in ``pick_font`` below.

The script renders the six showcase pages of ``main.typ`` twice:

  * ``preview/NN-<slug>.png``  -- one full-size image per page, embedded in README.md
  * ``thumbnail.png``          -- a 2x3 montage used as the repo social preview
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

# --- what to show ----------------------------------------------------------

# (page number in main.pdf, output slug, Chinese caption)
SHOWCASE = [
    (1, "cover", "封面与标题信息"),
    (2, "outline", "自动生成的目录"),
    (4, "text", "文字、圆形列表与红色强调"),
    (7, "table", "红色表头的斑马线表格"),
    (8, "code", "自动编号的代码块"),
    (15, "end", "全屏结束页"),
]

GRID = [1, 2, 4, 7, 8, 15]  # page order inside the montage, row by row

# --- look ------------------------------------------------------------------

SCU_RED = (149, 42, 31)
SCU_DARK = (74, 21, 15)
CANVAS = (247, 245, 244)
SHADOW = (150, 140, 138)
BORDER = (216, 210, 208)
PAGE_RADIUS = 10
RENDER_PPI = 160
THUMB_SCALE = 0.46
CELL_GAP = 40
PAD = 70
TITLE_BAND = 150
CORNER_RADIUS = 16

FONT_CANDIDATES = [
    "msyh.ttc", "msyh.ttf", "msyhbd.ttc",
    "SourceHanSansSC-Regular.otf", "NotoSansSC-Regular.otf",
    "PingFang.ttc", "Hiragino Sans GB.ttc",
    "NotoSansCJK-Regular.ttc", "DejaVuSans.ttf", "arial.ttf",
]


def pick_font(size: int):
    """Best-effort font lookup; returns a Pillow default font as a last resort."""
    for name in FONT_CANDIDATES:
        for root in (Path(r"C:\Windows\Fonts"), Path("/usr/share/fonts"), Path("/Library/Fonts")):
            if not root.exists():
                continue
            for path in root.rglob(name):
                try:
                    return ImageFont.truetype(str(path), size)
                except OSError:
                    continue
    return ImageFont.load_default(size)


def rounded(img: Image.Image, radius: int) -> Image.Image:
    """Apply an anti-aliased rounded-corner alpha mask."""
    w, h = img.size
    s = 4
    mask = Image.new("L", (w * s, h * s), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w * s - 1, h * s - 1), radius * s, fill=255)
    mask = mask.resize((w, h), Image.LANCZOS)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def find_typst(explicit: str | None) -> str:
    if explicit:
        return explicit
    found = shutil.which("typst")
    if found:
        return found
    for guess in (
        Path(r"D:\typst-x86_64-pc-windows-msvc\typst.exe"),
        Path.home() / ".cargo" / "bin" / "typst",
    ):
        if guess.exists():
            return str(guess)
    sys.exit("typst not found; pass --typst /path/to/typst")


def render_pages(typst: str, repo: Path, tmp: Path, ppi: int) -> dict[int, Path]:
    tmp.mkdir(parents=True, exist_ok=True)
    cmd = [
        typst, "compile", "main.typ", str(tmp / "page-{p}.png"),
        "--format", "png", "--ppi", str(ppi),
    ]
    print("$", " ".join(cmd))
    subprocess.run(cmd, cwd=repo, check=True)
    pages = {}
    for p in tmp.glob("page-*.png"):
        pages[int(p.stem.split("-")[1])] = p
    if not pages:
        sys.exit("typst produced no pages")
    return pages


def build_montage(pages: dict[int, Path], out: Path) -> None:
    first = Image.open(pages[GRID[0]])
    pw, ph = first.size
    tw, th = int(pw * THUMB_SCALE), int(ph * THUMB_SCALE)
    cols, rows = 3, 2
    width = PAD * 2 + cols * tw + (cols - 1) * CELL_GAP
    height = TITLE_BAND + PAD + rows * th + (rows - 1) * CELL_GAP + PAD
    canvas = Image.new("RGB", (width, height), CANVAS)
    draw = ImageDraw.Draw(canvas)

    # accent rule + headings
    draw.rectangle((PAD, 74, PAD + 86, 82), fill=SCU_RED)
    draw.text((PAD, 100), "SCU Beamer for Typst", font=pick_font(46), fill=SCU_DARK)
    draw.text(
        (PAD, 152),
        "四川大学风格幻灯片模板 · smoothbars 导航 / 红色标题带 / 章节自动目录",
        font=pick_font(26),
        fill=(122, 112, 109),
    )

    for i, pageno in enumerate(GRID):
        r, c = divmod(i, cols)
        x = PAD + c * (tw + CELL_GAP)
        y = TITLE_BAND + PAD + r * (th + CELL_GAP)
        page = Image.open(pages[pageno]).resize((tw, th), Image.LANCZOS)
        # drop shadow
        sh = Image.new("RGBA", (tw + 24, th + 24), (0, 0, 0, 0))
        ImageDraw.Draw(sh).rounded_rectangle(
            (18, 20, tw + 6, th + 8), CORNER_RADIUS, fill=SHADOW + (150,)
        )
        sh = sh.filter(ImageFilter.GaussianBlur(11))
        canvas.paste(sh, (x - 18, y - 18), sh)
        # page + hairline border
        page_rgba = rounded(page.convert("RGB"), CORNER_RADIUS)
        canvas.paste(page_rgba, (x, y), page_rgba)
        draw.rounded_rectangle(
            (x, y, x + tw - 1, y + th - 1), CORNER_RADIUS, outline=BORDER, width=2
        )

    canvas.save(out, "PNG", optimize=True)
    print(f"wrote {out}  ({width}x{height})")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--typst")
    ap.add_argument("--ppi", type=int, default=RENDER_PPI)
    args = ap.parse_args()

    repo = Path(__file__).resolve().parent.parent
    typst = find_typst(args.typst)
    tmp = repo / ".preview-build"
    preview_dir = repo / "preview"
    preview_dir.mkdir(exist_ok=True)

    pages = render_pages(typst, repo, tmp, args.ppi)

    for pageno, slug, _caption in SHOWCASE:
        if pageno not in pages:
            sys.exit(f"main.typ has no page {pageno}")
        out = preview_dir / f"{pageno:02d}-{slug}.png"
        Image.open(pages[pageno]).save(out, "PNG", optimize=True)
        print(f"wrote {out}")

    build_montage(pages, repo / "thumbnail.png")

    shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
