#!/usr/bin/env bash
set -euo pipefail

OWNER="${1:-DataFrameworksCo}"
REPO="${2:-dataframework-site}"
DOMAIN="dataframework.site"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install it, then run: gh auth login"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login"
  exit 1
fi

if [[ ! -f index.html || ! -f CNAME ]]; then
  echo "Run this script from /home/seth/Documents/DataFrameworkPages"
  exit 1
fi

if ! gh repo view "${OWNER}/${REPO}" >/dev/null 2>&1; then
  gh repo create "${OWNER}/${REPO}" \
    --public \
    --description "Static GitHub Pages deployment for ${DOMAIN}"
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "https://github.com/${OWNER}/${REPO}.git"
else
  git remote add origin "https://github.com/${OWNER}/${REPO}.git"
fi

git push -u origin main

if gh api "repos/${OWNER}/${REPO}/pages" >/dev/null 2>&1; then
  gh api --method PUT "repos/${OWNER}/${REPO}/pages" \
    -f cname="${DOMAIN}" \
    -f "source[branch]=main" \
    -f "source[path]=/"
else
  gh api --method POST "repos/${OWNER}/${REPO}/pages" \
    -f cname="${DOMAIN}" \
    -f "source[branch]=main" \
    -f "source[path]=/"
fi

echo "GitHub Pages requested for https://${DOMAIN}"
echo "After DNS points to GitHub Pages, enable Enforce HTTPS in repository Settings > Pages if it is not already enabled."
