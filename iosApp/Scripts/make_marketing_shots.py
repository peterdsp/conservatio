"""Frames the app screenshots into App Store marketing images.

Reads iosApp/AppStore/screenshots/<lang>/<device>/*.png and writes
iosApp/AppStore/marketing/<lang>/<device>/ at the exact App Store sizes:
iPhone 6.9" 1320x2868 and iPad 13" 2064x2752.

The frame uses the website's palette and type (frost and slate, Albert Sans,
one teal accent), so the store page and conservatio.peterdsp.dev read as one
product.

    uv run --with pillow python iosApp/Scripts/make_marketing_shots.py
"""
import pathlib
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "AppStore" / "screenshots"
OUT = ROOT / "AppStore" / "marketing"
FONT = pathlib.Path(__file__).resolve().parent / "fonts" / "AlbertSans.ttf"

SIZES = {"iphone": (1320, 2868), "ipad": (2064, 2752)}
GROUND, SURFACE = (247, 249, 250), (236, 240, 242)
INK, MUTED, ACCENT = (31, 48, 56), (93, 107, 114), (13, 116, 128)

CAPTIONS = {
    "en": {
        "1-annotate": ("Mark damage\non the photo", "Numbered markers for every crack, flake and loss."),
        "2-pdf": ("Reports ready\nto hand over", "A professional PDF in English, Greek or both."),
        "3-detail": ("Every object,\nfully documented", "Materials, dimensions, photos and reports."),
        "4-objects": ("Your collection\nin one place", "Icons, ceramics, stone, metal and more."),
        "5-projects": ("Projects and clients\nin order", "Status, dates and budget for every job."),
    },
}


def font(size, weight):
    f = ImageFont.truetype(str(FONT), size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f


def background(w, h):
    # Ground at the top easing into surface at the bottom, like the site's sections.
    column = Image.new("RGB", (1, 256))
    for y in range(256):
        t = y / 255
        column.putpixel((0, y), tuple(round(GROUND[i] + (SURFACE[i] - GROUND[i]) * t) for i in range(3)))
    img = column.resize((w, h), Image.BILINEAR)
    # One faint teal glow behind the device, the only colour besides the rule.
    glow = Image.new("RGB", (w, h), (0, 0, 0))
    ImageDraw.Draw(glow).ellipse((-w * 0.2, h * 0.42, w * 1.2, h * 1.1), fill=(24, 18, 8))
    small = glow.resize((w // 8, h // 8)).filter(ImageFilter.GaussianBlur(w * 0.2 / 8)).resize((w, h), Image.BILINEAR)
    return ImageChops.subtract(img, small)


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.width - 1, img.height - 1), radius, fill=255)
    out = Image.new("RGBA", img.size)
    out.paste(img, (0, 0), mask)
    return out, mask


def compose(shot_path, device, title, line):
    w, h = SIZES[device]
    canvas = background(w, h).convert("RGBA")
    d = ImageDraw.Draw(canvas)
    pad = round(w * (0.08 if device == "iphone" else 0.1))

    title_font = font(round(w * (0.084 if device == "iphone" else 0.058)), "SemiBold")
    line_font = font(round(w * (0.036 if device == "iphone" else 0.025)), "Regular")
    y = round(h * 0.055)
    bottom = y
    for text in title.split("\n"):
        tw = d.textlength(text, font=title_font)
        d.text(((w - tw) / 2, y), text, font=title_font, fill=INK)
        bottom = y + sum(title_font.getmetrics())
        y += round(title_font.size * 1.08)
    # A short teal rule, the site's one accent, below the headline's last line.
    rule = round(w * 0.07)
    y = bottom + round(title_font.size * 0.25)
    d.rectangle(((w - rule) / 2, y, (w + rule) / 2, y + max(6, round(w * 0.005))), fill=ACCENT)
    y += round(title_font.size * 0.46)
    lw = d.textlength(line, font=line_font)
    d.text(((w - lw) / 2, y), line, font=line_font, fill=MUTED)
    y += round(line_font.size * 2.1)

    shot = Image.open(shot_path).convert("RGB")
    # Fit the whole screen, tab bar included, with a margin at the bottom.
    scale = min((w - 2 * pad) / shot.width, (h - y - round(h * 0.04)) / shot.height)
    shot = shot.resize((round(shot.width * scale), round(shot.height * scale)), Image.LANCZOS)
    radius = round(shot.width * (0.075 if device == "iphone" else 0.03))
    card, mask = rounded(shot, radius)

    x = (w - card.width) // 2
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_mask = Image.new("L", canvas.size, 0)
    shadow_mask.paste(mask, (x, y + round(w * 0.015)))
    blurred = shadow_mask.resize((w // 4, h // 4)).filter(ImageFilter.GaussianBlur(w * 0.03 / 4)).resize((w, h), Image.BILINEAR)
    shadow.putalpha(blurred.point(lambda a: int(a * 0.22)))
    canvas = Image.alpha_composite(canvas, shadow)
    # A hairline in ink keeps the light screenshot apart from the light ground.
    edge = Image.new("RGBA", card.size, (0, 0, 0, 0))
    ImageDraw.Draw(edge).rounded_rectangle((0, 0, card.width - 1, card.height - 1), radius,
                                           outline=INK + (40,), width=max(2, w // 600))
    canvas.alpha_composite(card, (x, y))
    canvas.alpha_composite(edge, (x, y))
    return canvas.convert("RGB")


def main():
    for lang, captions in CAPTIONS.items():
        for device in SIZES:
            src_dir, out_dir = SRC / lang / device, OUT / lang / device
            out_dir.mkdir(parents=True, exist_ok=True)
            for shot in sorted(src_dir.glob("*.png")):
                title, line = captions[shot.stem]
                image = compose(shot, device, title, line)
                assert image.size == SIZES[device]
                image.save(out_dir / shot.name, optimize=True)
                print(out_dir.relative_to(ROOT) / shot.name)


if __name__ == "__main__":
    main()
