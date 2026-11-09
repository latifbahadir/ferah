# ADR-0004: App Store dışı dağıtım ve Tam Disk Erişimi

- **Durum:** Kabul edildi
- **Tarih:** 2026-11-09

## Bağlam

App Sandbox, başka uygulamaların kalıntılarına, `~/Library` geneline ve geliştirici araçlarının dizinlerine erişimi engeller. Bu, Ferah'ın temel işlevini imkânsız kılar.

## Karar

- Ferah **sandbox'sız** çalışır ve Mac App Store'da yayınlanmaz.
- Dağıtım: GitHub Releases üzerinden Developer ID ile imzalanmış ve notarize edilmiş DMG; ek olarak Homebrew tap.
- Kullanıcıdan **Tam Disk Erişimi** istenir; ilk açılışta neden gerektiği açıklanır ve Sistem Ayarları'nın ilgili paneli açılır. Erişim yoksa kısmi tarama yapılır ve eksik kalan alanlar belirtilir.

## Sonuçlar

- İmzalama/notarization için Apple Developer hesabı gerekir (v1.0'a kadar yerel derleme yeterli).
- Güvenlik sorumluluğu tamamen bizdedir; bkz. korunan yollar ve ADR-0002/0003.
