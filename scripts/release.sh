#!/bin/sh
set -eu
REPO="/vol1/fpk-converter"; OUT="/vol1/dist"
FN_PACK="${FN_PACK:-/vol1/.tools/fnpack}"; BRANCH="${1:-feature/dual-worker}"
cd "$REPO"
V=$(sed -n "s/^VERSION = '\(.*\)'/\1/p" app/fpkconverter/fpk_converter.py)
M=$(sed -n 's/^version *= *\(.*\)/\1/p' manifest | tr -d ' ')
[ -n "$V" ] || { echo "无法读取 VERSION"; exit 1; }
[ "$V" = "$M" ] || { echo "版本不一致: $V vs $M"; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "工作区不干净"; git status --short; exit 1; }
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
git archive "$BRANCH" | tar -x -C "$TMP"
[ -x "$FN_PACK" ] || { echo "找不到 fnpack"; exit 1; }
( cd "$TMP" && "$FN_PACK" build -d . ) || { echo "打包失败"; exit 1; }
mkdir -p "$OUT"; rm -f "$OUT"/*.fpk
mv -f "$TMP/fpkconverter.fpk" "$OUT/fpkconverter-v${V}.fpk"
chmod 644 "$OUT/fpkconverter-v${V}.fpk"; chmod 755 "$OUT"
ls -l "$OUT/fpkconverter-v${V}.fpk"
