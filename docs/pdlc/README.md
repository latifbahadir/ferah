# PDLC — Ürün Geliştirme Yaşam Döngüsü

PDLC, **"neyi ve neden"** yaptığımızı yönetir. SDLC ise **"nasıl"** yaptığımızı ([../sdlc](../sdlc/README.md)).

```
01 Keşif ──► 02 Tanımlama ──► 03 Planlama ──► (SDLC: geliştirme) ──► 04 Lansman ──► 05 Öğrenme
   ▲                                                                                      │
   └──────────────────────────────── geri bildirim ◄───────────────────────────────────────┘
```

| Aşama | Klasör | Çıktı | Çıkış kriteri |
|---|---|---|---|
| 01 Keşif | [01-discovery](01-discovery/) | Problem tanımı, rakip analizi | Problem ve hedef kullanıcı yazılı |
| 02 Tanımlama | [02-definition](02-definition/) | Vizyon, PRD (gereksinimler) | Gereksinimler ID'li ve onaylı |
| 03 Planlama | [03-planning](03-planning/) | Yol haritası, milestone'lar, issue'lar | Her gereksinim ≥1 issue'ya bağlı |
| 04 Lansman | [04-launch](04-launch/) | Sürüm notları, duyuru | Release yayınlandı |
| 05 Öğrenme | [05-learn](05-learn/) | Retrospektif, metrik, yeni fikirler | Öğrenimler yeni issue'lara dönüştü |

## Kurallar

- Yeni bir ürün fikri önce `type: idea` etiketli bir issue olarak açılır, kabul edilirse PRD'ye girer.
- PRD'deki her gereksinim (`FR-…`, `NFR-…`) bir veya daha fazla issue'ya bağlanır; issue açıklamasında gereksinim ID'si yazılır.
- Her milestone sonunda `05-learn/retrospectives/` altına kısa bir retrospektif eklenir.
