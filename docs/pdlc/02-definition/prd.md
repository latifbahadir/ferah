# PRD — Ürün Gereksinimleri

Her gereksinimin bir ID'si vardır. Issue'lar bu ID'lere referans verir.

## Ortak

| ID | Gereksinim |
|---|---|
| FR-CORE-01 | Her bulgu şunları içerir: başlık, yol(lar), boyut, güvenlik seviyesi (🟢 yeniden üretilebilir / 🟡 kullanıcı dosyası / 🔴 uygulama), gerekçe, güven skoru, önerilen eylem. |
| FR-CORE-02 | Hiçbir eylem kullanıcı onayı olmadan çalışmaz. Onay; arayüzde açık bir tıklama veya CLI'da etkileşimli onay / açık `--yes` bayrağıdır. |
| FR-CORE-03 | Silme = Çöp Sepeti'ne taşıma veya aracın resmi temizlik komutu. Doğrudan kalıcı silme yoktur. |
| FR-CORE-04 | Her işlem geçmişe yazılır (ne, nereden, ne kadar, ne zaman) ve Çöp Sepeti'ndekiler geri alınabilir. |
| FR-CORE-05 | Korunan yollar (sistem dizinleri vb.) hiçbir koşulda hedeflenemez. |
| FR-CORE-06 | Tam Disk Erişimi yoksa kullanıcı açıklayıcı bir ilk açılış akışıyla yönlendirilir; erişim olmadan da kısmi tarama çalışır. |

## Geliştirici çöpü (v0.1)

| ID | Gereksinim |
|---|---|
| FR-DEV-01 | Xcode: DerivedData, Archives, iOS/watchOS DeviceSupport, kullanılamayan simulator'lar, eski simulator runtime'ları. |
| FR-DEV-02 | `node_modules`: proje kökünü bulur; projenin son git commit / son değişiklik tarihine göre "terk edilmiş" skoru verir. |
| FR-DEV-03 | Paket yöneticisi önbellekleri: npm, yarn, pnpm, Homebrew, pip, CocoaPods, SwiftPM. |
| FR-DEV-04 | Docker: kullanılmayan imajlar, durmuş container'lar, build cache (Docker'ın kendi komutlarıyla). |
| FR-DEV-05 | Gradle önbellekleri, Rust `target`, Python venv / `.venv` klasörleri. |

## Büyük dosyalar (v0.2)

| ID | Gereksinim |
|---|---|
| FR-BIG-01 | Kullanıcının seçtiği dizinlerde eşik üstü dosyaları boyut ve son erişim tarihine göre listeler. |
| FR-BIG-02 | İçerik özetine (hash) dayalı kopya dosya tespiti. |
| FR-BIG-03 | Downloads yaşlanma analizi; kurulmuş uygulamaya ait DMG/PKG'leri ve açılmış arşivleri işaretler. |
| FR-BIG-04 | Dosya türüne göre öneri ("harici diske taşı", "arşivi sil, açılmış hali var" vb.). |

## Uygulama kaldırıcı (v0.3)

| ID | Gereksinim |
|---|---|
| FR-APP-01 | Spotlight metadata (`kMDItemLastUsedDate`, `kMDItemUseCount`) ile "hiç açılmadı" / "N gündür açılmadı" listeleri. |
| FR-APP-02 | Bundle ID ile kalıntı eşleştirme: Application Support, Caches, Preferences, Containers, Group Containers, LaunchAgents, Saved Application State, Logs. |
| FR-APP-03 | Homebrew cask ile kurulanlar `brew uninstall --cask` ile kaldırılır; App Store uygulamaları işaretlenir. |
| FR-APP-04 | Kaldırma öncesi tüm etkilenecek yolların ön izlemesi. |

## Sürekli ferahlık (v0.4)

| ID | Gereksinim |
|---|---|
| FR-BG-01 | Menü çubuğu yardımcısı; oturum açılışında başlatma seçeneği. |
| FR-BG-02 | Kural motoru: kullanıcı tanımlı kurallar (ör. "Downloads'taki 60 günden eski DMG'ler") yalnızca **öneri kuyruğuna** ekler. |
| FR-BG-03 | Downloads klasörünü izleme (FSEvents); kurulumdan sonra DMG için öneri. |
| FR-BG-04 | Haftalık özet bildirimi: "X GB ferahlatılabilir". |

## CLI (v0.1'den itibaren)

| ID | Gereksinim |
|---|---|
| FR-CLI-01 | `ferah scan [--dev|--big|--apps] [--json]` çekirdekle aynı bulguları üretir. |
| FR-CLI-02 | `ferah clean` seçilen bulguları etkileşimli onayla temizler; `--yes` yalnızca açık kullanımla. |
| FR-CLI-03 | `ferah history` ve `ferah undo` geçmişi gösterir / geri alır. |

## Fonksiyonel olmayan gereksinimler

| ID | Gereksinim |
|---|---|
| NFR-01 | macOS 14 Sonoma ve üzeri, Apple Silicon ve Intel. |
| NFR-02 | Geliştirici çöpü taraması tipik bir ev dizininde < 30 sn hedefler; tarama iptal edilebilir. |
| NFR-03 | Arka plan yardımcısı boşta ihmal edilebilir CPU ve < 50 MB bellek kullanır. |
| NFR-04 | Ağ erişimi yok, telemetri yok. Tüm veri yerelde kalır. |
| NFR-05 | Çekirdek mantığın birim test kapsamı yüksek tutulur; silme yolları %100 test edilir. |
| NFR-06 | Arayüz Türkçe; yerelleştirmeye hazır (String Catalog). |
