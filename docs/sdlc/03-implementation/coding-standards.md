# Kod Standartları

- **Dil:** Swift 6, strict concurrency açık. Tarayıcılar `Sendable`, tarama `async`.
- **Adlandırma:** Kod tanımlayıcıları İngilizce; kullanıcıya görünen metinler Türkçe ve String Catalog üzerinden.
- **Biçim:** `swift-format` (yapılandırması repo kökünde). CI'da denetlenir.
- **Katmanlar:** UI hiçbir zaman dosya sistemine doğrudan dokunmaz; her şey FerahCore üzerinden.
- **Yasaklar:**
  - `FileManager.removeItem`, `rm`, `Process` ile serbest kabuk komutu
  - Onay akışını atlayan herhangi bir kısayol
  - Ağ erişimi
- **Hata yönetimi:** Tarayıcı hatası taramayı durdurmaz; hata bulgu listesinde "taranamadı" olarak gösterilir.
- **Performans:** Büyük dizin taramaları iptal edilebilir (`Task.checkCancellation()`), derin dizinlerde paralel ama sınırlı.
