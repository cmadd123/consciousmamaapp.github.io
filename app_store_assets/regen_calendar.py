"""
Regenerate 03_calendar.png marketing screenshots from the source raw screenshot
(1000004257.png) with the corrected headline (no em-dash artifact).

The previous version had "Never miss a playdate — or the pediatrician." with an
em-dash that line-wrapped weirdly, leaving a stray horizontal line above
"pediatrician." Fixed: same headline without the em-dash.

Outputs:
- ios_6.5_marketing/03_calendar.png  (1284x2778)
- ios_6.7_marketing/03_calendar.png  (1290x2796)
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

SOURCE = r"C:\Users\cmadd\Downloads\1000004257.png"
BASE = r"C:\Users\cmadd\Documents\GitHub\consciousmamaapp.github.io\app_store_assets"

HEADLINE_L1 = "Never miss a playdate"
HEADLINE_L2 = "or the pediatrician."
HEADLINE_COLOR = (42, 111, 103)  # #2A6F67 dark teal

GRADIENT_TOP = (215, 242, 235)    # #D7F2EB teal
GRADIENT_BOTTOM = (255, 233, 225)  # #FFE9E1 peach

FONT_CANDIDATES = [
    r"C:\Windows\Fonts\segoeuib.ttf",  # Segoe UI Bold (matches other marketing PNGs)
    r"C:\Windows\Fonts\seguisb.ttf",  # Segoe UI Semibold fallback
    r"C:\Windows\Fonts\arialbd.ttf",  # Arial Bold fallback
]


def find_font(size):
    for candidate in FONT_CANDIDATES:
        if os.path.exists(candidate):
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def make_gradient(w, h):
    img = Image.new("RGB", (w, h), GRADIENT_TOP)
    px = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        r = int(GRADIENT_TOP[0] + (GRADIENT_BOTTOM[0] - GRADIENT_TOP[0]) * t)
        g = int(GRADIENT_TOP[1] + (GRADIENT_BOTTOM[1] - GRADIENT_TOP[1]) * t)
        b = int(GRADIENT_TOP[2] + (GRADIENT_BOTTOM[2] - GRADIENT_TOP[2]) * t)
        for x in range(w):
            px[x, y] = (r, g, b)
    return img


def rounded_corner_mask(size, radius):
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), size], radius=radius, fill=255)
    return mask


def make_marketing(out_path, canvas_size):
    cw, ch = canvas_size
    canvas = make_gradient(cw, ch)

    # Headline area — top ~18% of canvas
    headline_top_pct = 0.055
    headline_size = int(cw * 0.068)  # ~88px @ 1290 width
    line_gap = int(headline_size * 0.18)

    font = find_font(headline_size)
    draw = ImageDraw.Draw(canvas)

    # Measure lines
    def text_width(text):
        bbox = draw.textbbox((0, 0), text, font=font)
        return bbox[2] - bbox[0], bbox[3] - bbox[1]

    w1, h1 = text_width(HEADLINE_L1)
    w2, h2 = text_width(HEADLINE_L2)

    y = int(ch * headline_top_pct)
    draw.text(((cw - w1) // 2, y), HEADLINE_L1, fill=HEADLINE_COLOR, font=font)
    y += h1 + line_gap
    draw.text(((cw - w2) // 2, y), HEADLINE_L2, fill=HEADLINE_COLOR, font=font)
    headline_bottom = y + h2

    # Device screenshot
    src = Image.open(SOURCE).convert("RGBA")
    sw, sh = src.size
    # Scale device width to ~78% of canvas
    target_w = int(cw * 0.78)
    scale = target_w / sw
    target_h = int(sh * scale)
    src_resized = src.resize((target_w, target_h), Image.LANCZOS)

    # Rounded corners
    radius = int(target_w * 0.075)
    mask = rounded_corner_mask((target_w, target_h), radius)

    # Drop shadow
    shadow_offset = int(cw * 0.005)
    shadow_blur = int(cw * 0.020)
    shadow = Image.new("RGBA", (target_w + shadow_blur * 4, target_h + shadow_blur * 4), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        [(shadow_blur * 2, shadow_blur * 2), (shadow_blur * 2 + target_w, shadow_blur * 2 + target_h)],
        radius=radius,
        fill=(0, 0, 0, 75),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(shadow_blur))

    # Place device
    device_top = headline_bottom + int(ch * 0.045)
    device_x = (cw - target_w) // 2

    # Paste shadow first
    canvas_rgba = canvas.convert("RGBA")
    canvas_rgba.alpha_composite(
        shadow,
        (device_x - shadow_blur * 2 + shadow_offset, device_top - shadow_blur * 2 + shadow_offset),
    )

    # Paste device with rounded mask
    device_clipped = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    device_clipped.paste(src_resized, (0, 0), mask)
    canvas_rgba.alpha_composite(device_clipped, (device_x, device_top))

    canvas_rgb = canvas_rgba.convert("RGB")
    canvas_rgb.save(out_path, "PNG", optimize=True)
    print(f"wrote {out_path}  {canvas_size}")


if __name__ == "__main__":
    make_marketing(os.path.join(BASE, "ios_6.7_marketing", "03_calendar.png"), (1290, 2796))
    make_marketing(os.path.join(BASE, "ios_6.5_marketing", "03_calendar.png"), (1284, 2778))
    print("done")
