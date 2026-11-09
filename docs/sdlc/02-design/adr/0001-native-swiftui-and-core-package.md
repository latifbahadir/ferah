# ADR-0001: Native SwiftUI uygulaması + bağımsız çekirdek paket

- **Durum:** Kabul edildi
- **Tarih:** 2026-11-09

## Bağlam

Ferah hem bir masaüstü uygulaması hem de bir CLI sunacak; arka planda hafif çalışmalı ve dosya sistemine derin erişmeli.

## Karar

- Arayüz **SwiftUI** ile native yazılır; Electron/web tabanlı çözümler kullanılmaz.
- Tüm tarama ve eylem mantığı UI'dan bağımsız **FerahCore** Swift paketinde yer alır; uygulama ve CLI bu paketi paylaşır.
- Minimum hedef **macOS 14 Sonoma**; dil Swift 6 (strict concurrency).
- CLI argümanları için `swift-argument-parser`.

## Sonuçlar

- Çekirdek mantık `swift test` ile, Xcode'a ihtiyaç duymadan test edilebilir.
- macOS 14 tabanı `MenuBarExtra`, `SMAppService`, `@Observable` gibi modern API'leri sağlar.
- macOS 13 ve öncesi desteklenmez.
