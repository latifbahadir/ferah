# Ferah — ajan talimatları

- Tüm iş issue'lardan yürür. Kod değişikliği için önce ilgili issue'yu bul/aç.
- `main`'e asla doğrudan commit/push yapma. `feat|fix|docs|chore/<issue>-<kisa-ad>` branch'i aç.
- Her PR tek bir issue'ya bağlıdır ve açıklamasında `Closes #<issue>` bulunur (PR şablonunu kullan).
- PR'ları **asla** kendin birleştirme ya da auto-merge açma; birleştirme yalnızca maintainer'ın kararıdır.
- Kırmızı çizgi: onaysız silme yok, `rm`/`FileManager.removeItem` yok; yalnızca `ActionExecutor` (Çöp Sepeti / araç komutu).
- Süreç dokümanları: `docs/pdlc/`, `docs/sdlc/`. Mimari kararlar `docs/sdlc/02-design/adr/` altında ADR olarak yazılır.
- Kod tanımlayıcıları İngilizce, dokümanlar ve kullanıcıya görünen metinler Türkçe.
