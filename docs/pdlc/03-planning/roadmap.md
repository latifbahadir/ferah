# Yol Haritası

Her sürüm bir GitHub **milestone**'udur. Görevler milestone'lara bağlı issue'lar olarak takip edilir.

| Milestone | Tema | Kapsam (PRD) | Tamamlanma ölçütü |
|---|---|---|---|
| **v0.0 – Temel** | Repo, CI, iskelet | — | Uygulama + çekirdek paket + CLI derleniyor, CI yeşil |
| **v0.1 – Çekirdek & Geliştirici Çöpü** | Tarama motoru, eylem yürütücü, dev tarayıcıları, ilk arayüz, CLI | FR-CORE-*, FR-DEV-*, FR-CLI-* | Kendi Mac'imde dev çöpü güvenle temizleniyor |
| **v0.2 – Büyük Dosyalar** | Büyük/kopya dosyalar, Downloads analizi | FR-BIG-* | Downloads ve proje dizinleri analiz edilebiliyor |
| **v0.3 – Uygulama Kaldırıcı** | Kullanılmayan uygulamalar + kalıntılar | FR-APP-* | Bir uygulama tüm kalıntılarıyla güvenle kaldırılabiliyor |
| **v0.4 – Sürekli Ferahlık** | Menü çubuğu, kurallar, izleme, bildirim | FR-BG-* | Ferah temizlik zamanını kendisi haber veriyor |
| **v1.0 – Yayın** | İmzalı/notarize DMG, Homebrew tap, dokümantasyon | NFR-* | GitHub Releases'tan kurulabilir |

İlkeler: Her milestone kendi başına kullanılabilir bir uygulama bırakır. Kapsam büyürse yeni milestone açılır; mevcut milestone şişirilmez.
