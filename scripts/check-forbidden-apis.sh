#!/usr/bin/env bash
# Yasaklı API denetimi — ADR-0002 (onay kırmızı çizgisi) ve ADR-0003 (önce Çöp Sepeti).
#
# Dosya sistemini değiştiren veya süreç başlatan API'ler yalnızca
# Sources/FerahCore/Actions/ altında (ActionExecutor ve yardımcıları) kullanılabilir.
# Böylece hiçbir kod yolu onay akışını ve korunan yollar kontrolünü atlayamaz.
#
# Kullanım: scripts/check-forbidden-apis.sh [kök-dizin]   (varsayılan: repo kökü)
# Testler (Tests/) taranmaz; geçici fixture dizinlerini temizleyebilmeleri gerekir.

set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SCAN_DIRS=(Sources App)
ALLOWED_DIR="Sources/FerahCore/Actions/"

# "desen|açıklama" — desenler grep -E sözdizimindedir.
RULES=(
  '\.removeItem[[:space:]]*\(|FileManager.removeItem: kalıcı silme yasak, ActionExecutor ile Çöp Sepetine taşı'
  '\.trashItem[[:space:]]*\(|FileManager.trashItem: yalnızca ActionExecutor kullanabilir'
  '\.moveItem[[:space:]]*\(|FileManager.moveItem: yalnızca ActionExecutor kullanabilir'
  '\.replaceItem(At)?[[:space:]]*\(|FileManager.replaceItem: yalnızca ActionExecutor kullanabilir'
  '\.recycle[[:space:]]*\(|NSWorkspace.recycle: yalnızca ActionExecutor kullanabilir'
  '(^|[^[:alnum:]_.])(unlink|rmdir|removefile|remove)[[:space:]]*\([[:space:]]*[^)[:space:]]|POSIX silme fonksiyonları yasak'
  '(^|[^[:alnum:]_.])Process[[:space:]]*\(|Process: serbest süreç başlatma yasak, ToolCommand beyaz listesini kullan'
  'NSTask|posix_spawn|(^|[^[:alnum:]_.])system[[:space:]]*\(|Süreç başlatma yasak'
  '"(/bin/)?rm"|"(/bin/)?rm |rm komutu yasak'
)

found=0
for dir in "${SCAN_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  while IFS= read -r -d '' file; do
    case "$file" in
      "$ALLOWED_DIR"*) continue ;;
    esac
    for rule in "${RULES[@]}"; do
      pattern="${rule%|*}"
      message="${rule##*|}"
      while IFS= read -r hit; do
        [ -n "$hit" ] || continue
        line="${hit%%:*}"
        echo "::error file=$file,line=$line::$message"
        echo "  $file:$hit"
        found=1
      done < <(grep -nE "$pattern" "$file" | grep -vE '^[0-9]+:[[:space:]]*//' || true)
    done
  done < <(find "$dir" -name '*.swift' -print0)
done

if [ "$found" -ne 0 ]; then
  echo
  echo "Yasaklı API kullanımı bulundu. Dosya işlemleri yalnızca $ALLOWED_DIR altındaki ActionExecutor üzerinden yapılmalı."
  echo "Bkz. docs/sdlc/02-design/adr/0002-approval-red-line.md ve 0003-trash-first.md"
  exit 1
fi

echo "✓ Yasaklı API kullanımı yok."
