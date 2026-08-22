#!/usr/bin/env python3
"""Generate sitemap.xml from the git-tracked public HTML pages.

Systems-not-legwork: re-run this whenever content changes (or wire it into
CI) instead of hand-maintaining a sitemap. Emits pretty URLs matching the
pages' own canonicals (dir/index.html -> /dir/, root foo.html -> /foo),
with per-page lastmod pulled from git history.

Usage:  python scripts/gen_sitemap.py   (run from repo root)
"""
import subprocess
import sys

BASE = "https://momrise.app"

# Path prefixes that are private tools or non-content (never in the sitemap).
EXCLUDE_PREFIXES = (
    "admin/", "creator/", "auth/", "oauth/", "web/", "s/", "c/",
    "node_modules/", "functions/", ".well-known/",
)
# Individual files to skip.
EXCLUDE_FILES = {"404.html"}

# changefreq / priority by URL shape.
def rank(url_path):
    if url_path == "/":
        return ("weekly", "1.0")
    if url_path.startswith("/r/"):
        return ("monthly", "0.8")       # recipes = the traffic wedge
    if url_path.startswith("/compare/"):
        return ("monthly", "0.8")       # comparison-authority content
    if url_path.startswith("/meal-ideas"):
        return ("weekly", "0.9")        # hero free tool / link magnet
    if url_path.startswith("/for-creators"):
        return ("monthly", "0.7")       # creator-recruitment content
    return ("monthly", "0.5")           # marketing / legal


def tracked_html():
    out = subprocess.run(
        ["git", "ls-files", "*.html"], capture_output=True, text=True, check=True
    ).stdout.splitlines()
    for f in out:
        f = f.strip().replace("\\", "/")
        if not f or f in EXCLUDE_FILES:
            continue
        if any(f.startswith(p) for p in EXCLUDE_PREFIXES):
            continue
        # Search-engine ownership-verification files aren't crawlable pages.
        if f.startswith("google") and f.endswith(".html"):
            continue
        yield f


def to_url(path):
    if path == "index.html":
        return "/"
    if path.endswith("/index.html"):
        return "/" + path[: -len("index.html")]   # dir/index.html -> /dir/
    if path.endswith(".html"):
        return "/" + path[: -len(".html")]         # foo.html -> /foo
    return "/" + path


def lastmod(path):
    try:
        d = subprocess.run(
            ["git", "log", "-1", "--format=%cs", "--", path],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
        return d or None
    except subprocess.CalledProcessError:
        return None


def main():
    urls = []
    for path in sorted(tracked_html()):
        loc = BASE + to_url(path)
        cf, pr = rank(to_url(path))
        urls.append((loc, lastmod(path), cf, pr))

    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    for loc, lm, cf, pr in urls:
        lines.append("  <url>")
        lines.append(f"    <loc>{loc}</loc>")
        if lm:
            lines.append(f"    <lastmod>{lm}</lastmod>")
        lines.append(f"    <changefreq>{cf}</changefreq>")
        lines.append(f"    <priority>{pr}</priority>")
        lines.append("  </url>")
    lines.append("</urlset>")

    with open("sitemap.xml", "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines) + "\n")

    print(f"Wrote sitemap.xml with {len(urls)} URLs")
    sys.exit(0)


if __name__ == "__main__":
    main()
