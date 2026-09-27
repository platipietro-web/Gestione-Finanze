#!/bin/sh
# Il progetto sta sulla Scrivania, sincronizzata con iCloud Drive. iCloud
# aggiunge attributi ai file compilati e la firma delle build iOS fallisce
# ("resource fork, Finder information, or similar detritus not allowed").
# Questo script porta la cartella build fuori da iCloud con un collegamento.
# Rilancialo dopo un `flutter clean`.
set -e
cd "$(dirname "$0")/.."
TARGET="${PATRIMONIO_BUILD_DIR:-$HOME/development/patrimonio-build}"
mkdir -p "$TARGET"
if [ -L build ]; then
  echo "build punta già a $(readlink build)"
  exit 0
fi
rm -rf build
ln -s "$TARGET" build
echo "build -> $TARGET"
