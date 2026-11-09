# ADR-0003: Önce Çöp Sepeti, kalıcı silme yok

- **Durum:** Kabul edildi
- **Tarih:** 2026-11-09

## Bağlam

Yanlış bir önerinin bedeli geri alınamaz veri kaybı olmamalı.

## Karar

- Dosya eylemleri yalnızca `FileManager.trashItem` ile Çöp Sepeti'ne taşımadır.
- Araçların kendi verisi (Docker imajları, simulator'lar, Homebrew önbelleği) için yalnızca beyaz listedeki resmi komutlar çalıştırılır (`docker image prune`, `xcrun simctl delete unavailable`, `brew cleanup` vb.).
- `FileManager.removeItem`, `rm` ve serbest kabuk komutları kod tabanında yasaktır; lint kuralı ile denetlenir.
- Her eylem geçmişe yazılır; Çöp Sepeti'ne taşınanlar geçmişten geri yüklenebilir.

## Sonuçlar

- Disk alanı, kullanıcı Çöp Sepeti'ni boşaltana kadar gerçekten boşalmaz; arayüz bunu açıkça belirtir.
- Araç komutlarıyla yapılan temizlikler (ör. Docker) geri alınamaz; bu eylemler 🔴/🟢 seviyesine göre ek uyarıyla gösterilir.
