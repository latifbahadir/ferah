# Ferah

> Mac'in hep ferah kalsın.

**Ferah**, geliştiriciler için tasarlanmış, açıklanabilir öneriler sunan bir macOS temizlik asistanıdır. Gereksiz uygulamaları, yeniden üretilebilir geliştirici çöpünü ve unutulmuş büyük dosyaları bulur; *neden* silinebileceklerini açıklar ve **yalnızca senin onayınla** temizler.

*English: Ferah ("spacious, airy" in Turkish) is a developer‑focused macOS cleanup assistant that explains every recommendation and never removes anything without explicit approval.*

> 🚧 **Durum:** Erken geliştirme (v0.1 öncesi). Yol haritası için [docs/pdlc/03-planning/roadmap.md](docs/pdlc/03-planning/roadmap.md).

## Ne yapacak?

| Modül | Açıklama |
|---|---|
| 🧑‍💻 **Geliştirici çöpü** | Xcode DerivedData / Archives / DeviceSupport / eski simulator'lar, `node_modules`, npm·yarn·pnpm·Homebrew·pip·CocoaPods önbellekleri, Docker, Gradle, Rust `target`, Python venv |
| 📦 **Büyük dosyalar** | Boyut + son erişim sıralaması, kopya dosyalar, Downloads yaşlanma analizi, kurulmuş DMG/PKG tespiti |
| 🧹 **Uygulama kaldırıcı** | Hiç açılmamış / uzun süredir kullanılmayan uygulamalar, kalıntılarıyla birlikte kaldırma, Homebrew cask desteği |
| 🔔 **Sürekli ferahlık** | Menü çubuğu yardımcısı, kurallar, Downloads izleme, haftalık özet |
| ⌨️ **CLI** | Aynı çekirdek üzerinde `ferah scan` / `ferah clean` |

## İlkeler

1. **Onay kırmızı çizgidir.** Hiçbir şey onaysız silinmez — kurallar dahil. Kurallar yalnızca öneri üretir.
2. **Önce Çöp Sepeti.** Doğrudan `rm` yok; dosyalar Çöp Sepeti'ne taşınır ya da aracın kendi temizlik komutu kullanılır. Her işlem geçmişe yazılır.
3. **Açıklanabilirlik.** Her önerinin bir gerekçesi, boyutu ve güvenlik seviyesi vardır.
4. **Geliştirici odaklı.** Yeniden üretilebilir olan (🟢) ile kullanıcı verisi (🟡) ve uygulamalar (🔴) net biçimde ayrılır.

## Repo yapısı

```
.
├── docs/
│   ├── pdlc/   # Ürün yaşam döngüsü: keşif → tanım → planlama → lansman → öğrenme
│   └── sdlc/   # Yazılım yaşam döngüsü: gereksinim → tasarım → geliştirme → test → review → release → bakım
├── .github/    # Issue/PR şablonları, CI ve PR politikası iş akışları
├── CONTRIBUTING.md
├── SECURITY.md
└── CHANGELOG.md
```

## Çalışma biçimi

- Her iş bir **issue** ile başlar; her **PR** tek bir issue'yu kapatır (`Closes #N`).
- `main` korumalıdır: doğrudan push yapılamaz, yalnızca PR ile ve maintainer'ın birleştirmesiyle değişir.
- Ayrıntılar: [docs/sdlc/README.md](docs/sdlc/README.md) ve [CONTRIBUTING.md](CONTRIBUTING.md).

## Gereksinimler

- macOS 14 Sonoma veya üzeri
- Geliştirme: Xcode 16+ / Swift 6

## Lisans

[MIT](LICENSE)
