# Test Stratejisi

| Seviye | Ne | Nasıl |
|---|---|---|
| Birim | Modeller, skorlar, kural motoru, korunan yollar | Swift Testing (`swift test`) |
| Tarayıcı | Her `JunkScanner` | Geçici dizinde sahte dosya ağacı (fixture) oluşturulur, beklenen bulgular doğrulanır |
| Eylem | `ActionExecutor`, geçmiş, geri alma | Yalnızca geçici dizindeki dosyalar üzerinde; gerçek ev dizinine asla dokunulmaz |
| Güvenlik | Korunan yollar, onaysız yürütme denemeleri, symlink kaçışları | Zorunlu regresyon testleri |
| UI | Kritik onay akışları | XCUITest (v0.1 sonrası) |
| Manuel | Gerçek Mac'te tarama | Her milestone sonunda, yalnızca "dry-run" ve ardından kontrollü onay ile |

## Kurallar

- Silme yolunu etkileyen her PR, ilgili güvenlik testini ekler veya günceller.
- Testler ağ erişimi ve gerçek kullanıcı dizini gerektirmez; `ScanContext` ev dizinini enjekte edilebilir kılar.
- CI'da `swift test` her PR'da çalışır ve birleştirme için zorunludur.
