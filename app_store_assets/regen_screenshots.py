"""
Regenerate all App Store marketing screenshots from Haley's new raw shots.

For each source phone screenshot, produces two marketing-wrapped renders:
- ios_6.7_marketing/<NN>_<slug>.png  (1290x2796 — iPhone 15 Pro Max)
- ios_6.5_marketing/<NN>_<slug>.png  (1284x2778 — iPhone 8 Plus / older)

Marketing wrap (matches the prior 03_calendar template):
- Teal -> peach gradient background
- Centered 2-line headline in Segoe UI Bold, dark teal #2A6F67
- Phone screenshot centered, rounded corners, drop shadow

Output filenames are renamed for the new screenshot set since features
shifted (Recipes, Meal Plan with budget, Learning Path are new).
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

DOWNLOADS = r"C:\Users\cmadd\Downloads"
BASE = r"C:\Users\cmadd\Documents\GitHub\consciousmamaapp.github.io\app_store_assets"

HEADLINE_COLOR = (42, 111, 103)        # #2A6F67 dark teal
GRADIENT_TOP = (215, 242, 235)         # #D7F2EB
GRADIENT_BOTTOM = (255, 233, 225)      # #FFE9E1

FONT_CANDIDATES = [
    r"C:\Windows\Fonts\segoeuib.ttf",
    r"C:\Windows\Fonts\seguisb.ttf",
    r"C:\Windows\Fonts\arialbd.ttf",
]

# (source_file, output_slug, headline_l1, headline_l2)
SHOTS = [
    ("1000004283.png", "01_home",
     "Mom life,", "simplified."),
    ("1000004279.png", "02_recipes",
     "Every recipe,", "anywhere, saved."),
    ("1000004278.png", "03_meal_plan",
     "Plan the week.", "Hit the budget."),
    # Use the older shot (1000004257) instead of 1000004281 — that one
    # has populated event dots all month, 3pm playdate (not 12am), and
    # all kid filters active. Reads way more like a real, used calendar.
    ("1000004257.png", "04_calendar",
     "Never miss a playdate", "or the pediatrician."),
    ("1000004280.png", "05_milestones",
     "Every first,", "remembered."),
    ("1000004282.png", "06_learning_path",
     "Turn milestones", "into learning."),
    ("1000004284.png", "07_routines",
     "Everything", "in one place."),
]


def find_font(size):
    for c in FONT_CANDIDATES:
        if os.path.exists(c):
            return ImageFont.truetype(c, size)
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


def make_marketing(source_path, out_path, canvas_size, headline_l1, headline_l2):
    cw, ch = canvas_size
    canvas = make_gradient(cw, ch)

    headline_top_pct = 0.055
    headline_size = int(cw * 0.068)
    line_gap = int(headline_size * 0.18)

    font = find_font(headline_size)
    draw = ImageDraw.Draw(canvas)

    def text_size(text):
        bbox = draw.textbbox((0, 0), text, font=font)
        return bbox[2] - bbox[0], bbox[3] - bbox[1]

    w1, h1 = text_size(headline_l1)
    w2, h2 = text_size(headline_l2)

    y = int(ch * headline_top_pct)
    draw.text(((cw - w1) // 2, y), headline_l1, fill=HEADLINE_COLOR, font=font)
    y += h1 + line_gap
    draw.text(((cw - w2) // 2, y), headline_l2, fill=HEADLINE_COLOR, font=font)
    headline_bottom = y + h2

    src = Image.open(source_path).convert("RGBA")
    sw, sh = src.size
    target_w = int(cw * 0.78)
    scale = target_w / sw
    target_h = int(sh * scale)
    src_resized = src.resize((target_w, target_h), Image.LANCZOS)

    radius = int(target_w * 0.075)
    mask = rounded_corner_mask((target_w, target_h), radius)

    shadow_offset = int(cw * 0.005)
    shadow_blur = int(cw * 0.020)
    shadow = Image.new("RGBA",
                       (target_w + shadow_blur * 4, target_h + shadow_blur * 4),
                       (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        [(shadow_blur * 2, shadow_blur * 2),
         (shadow_blur * 2 + target_w, shadow_blur * 2 + target_h)],
        radius=radius, fill=(0, 0, 0, 75),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(shadow_blur))

    device_top = headline_bottom + int(ch * 0.045)
    device_x = (cw - target_w) // 2

    canvas_rgba = canvas.convert("RGBA")
    canvas_rgba.alpha_composite(
        shadow,
        (device_x - shadow_blur * 2 + shadow_offset,
         device_top - shadow_blur * 2 + shadow_offset),
    )

    device_clipped = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    device_clipped.paste(src_resized, (0, 0), mask)
    canvas_rgba.alpha_composite(device_clipped, (device_x, device_top))

    canvas_rgb = canvas_rgba.convert("RGB")
    canvas_rgb.save(out_path, "PNG", optimize=True)
    print(f"  wrote {os.path.relpath(out_path, BASE)}")


def main():
    out_67 = os.path.join(BASE, "ios_6.7_marketing")
    out_65 = os.path.join(BASE, "ios_6.5_marketing")
    os.makedirs(out_67, exist_ok=True)
    os.makedirs(out_65, exist_ok=True)

    # Clean out old screenshots so dropped/renamed ones don't linger.
    for d in (out_67, out_65):
        for fn in os.listdir(d):
            if fn.endswith(".png"):
                os.remove(os.path.join(d, fn))

    for source, slug, l1, l2 in SHOTS:
        src_path = os.path.join(DOWNLOADS, source)
        if not os.path.exists(src_path):
            print(f"  ! missing source: {src_path}")
            continue
        print(f"{slug}  '{l1} {l2}'")
        make_marketing(src_path, os.path.join(out_67, f"{slug}.png"),
                       (1290, 2796), l1, l2)
        make_marketing(src_path, os.path.join(out_65, f"{slug}.png"),
                       (1284, 2778), l1, l2)
    print("\ndone")


if __name__ == "__main__":
    main()
