"""Draws the v1.1 Play Store graphics: the feature graphic (homidev art from job
20261126-1452, approved by Homi, plus title text) and captioned phone
screenshots built from raw device captures. Run from the repo root:
python3 scripts/make_store_graphics.py"""
import os
from PIL import Image, ImageDraw, ImageFont

GREEN = (11, 110, 79)
GREEN_DARK = (7, 78, 56)
WHITE = (255, 255, 255)
S = 4  # supersampling factor

ART = 'app/assets/images/20261126-1452-live-healthy-vitals-image-01_raw.png'
OUT = 'store/graphics/phone_screenshots_v11'

# (output name, raw capture, caption) — upload in this order.
SCREENS = [
    ('01_home', 'store/graphics/screenshots/02_home.png', 'All your vitals\nin one place'),
    ('02_bp_history', 'store/graphics/screenshots/05_bp_history.png', 'See your trend\nover 7, 30 or 90 days'),
    ('03_summary', 'store/graphics/screenshots/10_bp_summary_v11.png',
     'Average, lowest, highest —\nmorning and evening'),
    ('04_report', 'store/graphics/screenshots/11_report_v11.png',
     'Free doctor report:\nshare a PDF on WhatsApp'),
    ('05_bp_entry', 'store/graphics/screenshots/03_bp_entry.png', 'Log blood pressure\nin seconds'),
    ('06_glucose', 'store/graphics/screenshots/04_glucose_entry.png', 'Blood sugar, fasting\nor after a meal'),
    ('07_family', 'store/graphics/screenshots/08_patients.png', 'Track parents and\nfamily in one account'),
    ('08_reminders', 'store/graphics/screenshots/07_reminders.png', 'Gentle daily\nreminders'),
    ('09_urdu', 'store/graphics/screenshots/09_urdu.png', 'In English\nand Urdu'),
]


def font(size, bold=True):
    name = 'DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf'
    return ImageFont.truetype(f'/usr/share/fonts/truetype/dejavu/{name}', size)


def gradient(w, h, top, bottom):
    mask = Image.linear_gradient('L').resize((w, h))
    return Image.composite(Image.new('RGB', (w, h), bottom), Image.new('RGB', (w, h), top), mask)


def feature_graphic(path):
    w, h = 1024, 500
    art = Image.open(ART).convert('RGB')
    # 1024x1024 art: the woman and phone sit in the band y≈220..720, the right half is open sky.
    img = art.crop((0, 215, 1024, 715)).resize((w * S, h * S), Image.LANCZOS)
    d = ImageDraw.Draw(img)
    u = S
    x = 520 * u
    d.text((x, 96 * u), 'LiveHealthy:', font=font(46 * u), fill=GREEN)
    d.text((x - 4 * u, 150 * u), 'Vitals', font=font(96 * u), fill=GREEN_DARK)
    d.text((x, 272 * u), 'BP · SpO2 · Pulse · Weight · Sugar', font=font(25 * u, bold=False), fill=GREEN_DARK)
    pill = 'Free doctor report (PDF)'
    f = font(27 * u)
    tw = d.textlength(pill, font=f)
    d.rounded_rectangle([x, 330 * u, x + tw + 48 * u, 386 * u], radius=28 * u, fill=GREEN)
    d.text((x + 24 * u, 343 * u), pill, font=f, fill=WHITE)
    img.resize((w, h), Image.LANCZOS).save(path)


def captioned(path, raw, caption):
    w, h = 1200, 2400
    img = gradient(w, h, (18, 138, 99), GREEN_DARK)
    d = ImageDraw.Draw(img)
    lines = caption.split('\n')
    y = 120
    f = font(76)
    for line in lines:
        tw = d.textlength(line, font=f)
        d.text(((w - tw) / 2, y), line, font=f, fill=WHITE)
        y += 100
    shot = Image.open(raw).convert('RGB')
    sw = 940
    shot = shot.resize((sw, round(shot.height * sw / shot.width)), Image.LANCZOS)
    top = 120 + 100 * len(lines) + 70
    frame = Image.new('L', shot.size, 0)
    ImageDraw.Draw(frame).rounded_rectangle([0, 0, shot.width, shot.height + 60], radius=48, fill=255)
    border = Image.new('RGB', (sw + 24, shot.height + 24), (10, 60, 44))
    bmask = Image.new('L', border.size, 0)
    ImageDraw.Draw(bmask).rounded_rectangle([0, 0, border.width, border.height + 60], radius=60, fill=255)
    img.paste(border, ((w - sw - 24) // 2, top - 12), bmask)
    img.paste(shot, ((w - sw) // 2, top), frame)  # runs off the bottom edge on purpose
    img.save(path)


if __name__ == '__main__':
    feature_graphic('store/graphics/feature_graphic.png')
    os.makedirs(OUT, exist_ok=True)
    for name, raw, caption in SCREENS:
        captioned(f'{OUT}/{name}.png', raw, caption)
    print('store graphics written')
