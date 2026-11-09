# Kod Standartları

- **Dil:** Swift 6, strict concurrency açık. Tarayıcılar `Sendable`, tarama `async`.
- **Adlandırma:** Kod tanımlayıcıları İngilizce; kullanıcıya görünen metinler Türkçe ve String Catalog üzerinden.
- **Biçim:** `swift-format` (Xcode araç zinciriyle gelir; yapılandırma: kök dizindeki `.swift-format`). CI'da `--strict` ile denetlenir.
  - Biçimlendir: `swift format format --in-place --recursive Package.swift Sources Tests App`
  - Denetle: `swift format lint --strict --recursive Package.swift Sources Tests App`
- **Yasaklı API denetimi:** `scripts/check-forbidden-apis.sh`. Dosya sistemini değiştiren veya süreç başlatan API'ler (`removeItem`, `trashItem`, `moveItem`, `unlink`, `Process`, `rm` …) yalnızca `Sources/FerahCore/Actions/` altında kullanılabilir. `Tests/` taranmaz. CI'da zorunludur.
- **Katmanlar:** UI hiçbir zaman dosya sistemine doğrudan dokunmaz; her şey FerahCore üzerinden.
- **Yasaklar:**
  - `FileManager.removeItem`, `rm`, `Process` ile serbest kabuk komutu
  - Onay akışını atlayan herhangi bir kısayol
  - Ağ erişimi
- **Hata yönetimi:** Tarayıcı hatası taramayı durdurmaz; hata bulgu listesinde "taranamadı" olarak gösterilir.
- **Performans:** Büyük dizin taramaları iptal edilebilir (`Task.checkCancellation()`), derin dizinlerde paralel ama sınırlı.
