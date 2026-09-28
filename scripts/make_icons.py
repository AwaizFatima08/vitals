"""Draws the LiveHealthy Vitals icon set (launcher, adaptive foreground,
Play Store 512, feature graphic) so they're reproducible without an image
model. Run from the repo root: python3 scripts/make_icons.py"""
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

GREEN = (11, 110, 79)
GREEN_DARK = (7, 78, 56)
WHITE = (255, 255, 255)
S = 4  # supersampling factor


def heart_points(cx, cy, size, n=400):
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x = 16 * math.sin(t) ** 3
        y = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        pts.append((cx + x * size / 34, cy - y * size / 34))
    return pts


def draw_mark(draw, cx, cy, size, heart_color=WHITE, line_color=GREEN):
    """White heart with an ECG pulse line across it."""
    draw.polygon(heart_points(cx, cy, size), fill=heart_color)
    w = size * 0.085  # thicker line survives 48dp launcher size
    u = size / 100
    y0 = cy + 2 * u
    # Peaks stay inside the heart: a taller spike used to poke through the
    # top notch and break the heart's outline.
    pts = [(-42, 0), (-18, 0), (-11, -14), (-3, 16), (6, -22), (14, 8), (20, 0), (42, 0)]
    pts = [(cx + x * u, y0 + y * u) for x, y in pts]
    draw.line(pts, fill=line_color, width=int(w), joint='curve')
    for p in (pts[0], pts[-1]):
        r = w / 2
        draw.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=line_color)


def gradient_bg(w, h=None):
    """Smooth top-left (lighter) to bottom-right (darker) diagonal gradient."""
    h = h or w
    light, dark = (18, 138, 99), GREEN_DARK
    gx = Image.linear_gradient('L').rotate(90).resize((w, h))  # 255 left -> 0 right
    gy = Image.linear_gradient('L').resize((w, h))  # 0 top -> 255 bottom
    mask = Image.blend(Image.eval(gx, lambda v: 255 - v), gy, 0.5)
    return Image.composite(Image.new('RGB', (w, h), dark), Image.new('RGB', (w, h), light), mask)


def launcher_icon(path, size=1024):
    big = size * S
    img = gradient_bg(big)
    d = ImageDraw.Draw(img)
    draw_mark(d, big / 2, big / 2 + big * 0.02, big * 0.64)
    img.resize((size, size), Image.LANCZOS).save(path)


def adaptive_foreground(path, size=1024):
    # Adaptive icons crop to the inner ~61%; keep the mark inside it.
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_mark(d, big / 2, big / 2 + big * 0.012, big * 0.56)  # inside the 66% adaptive safe zone
    img.resize((size, size), Image.LANCZOS).save(path)


def font(size, bold=True):
    for name in ['/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if bold else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf']:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


def feature_graphic(path, icon_path):
    w, h = 1024, 500
    img = gradient_bg(w * S, h * S).convert('RGBA')
    u = S
    # faint ECG line along the bottom, clear of the text
    line = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ld = ImageDraw.Draw(line)
    ys = 450 * u
    pts = [(0, ys), (700 * u, ys), (725 * u, ys - 22 * u), (745 * u, ys + 26 * u), (770 * u, ys - 40 * u),
           (790 * u, ys + 10 * u), (805 * u, ys), (w * S, ys)]
    ld.line(pts, fill=(255, 255, 255, 70), width=5 * u, joint='curve')
    img = Image.alpha_composite(img, line)
    overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.rounded_rectangle([70 * u, 120 * u, 330 * u, 380 * u], radius=56 * u, fill=(255, 255, 255, 255))
    draw_mark(od, 200 * u, 255 * u, 190 * u, heart_color=GREEN, line_color=WHITE)
    img = Image.alpha_composite(img, overlay).convert('RGB')
    d = ImageDraw.Draw(img)
    d.text((380 * u, 150 * u), 'LiveHealthy', font=font(64 * u), fill=WHITE)
    d.text((380 * u, 230 * u), 'Vitals', font=font(88 * u), fill=WHITE)
    d.text((383 * u, 345 * u), 'BP · SpO2 · Pulse · Weight · Glucose', font=font(30 * u, bold=False), fill=(220, 240, 232))
    img.resize((w, h), Image.LANCZOS).save(path)


if __name__ == '__main__':
    launcher_icon('app/assets/images/app_icon.png')
    adaptive_foreground('app/assets/images/app_icon_foreground.png')
    launcher_icon('store/graphics/app_icon_clean.png')
    launcher_icon('store/graphics/play_store_icon_512.png', size=512)
    feature_graphic('store/graphics/feature_graphic.png', 'store/graphics/app_icon_clean.png')
    print('icons written')
