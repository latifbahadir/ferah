# ADR-0002: Onay kırmızı çizgisi

- **Durum:** Kabul edildi
- **Tarih:** 2026-11-09

## Bağlam

Ferah kurallar ve arka plan izleme ile otomasyon sunacak. Otomasyonun kullanıcı verisini izinsiz silmesi ürünün güvenini tamamen yok eder.

## Karar

- Hiçbir eylem kullanıcı onayı olmadan çalışmaz. Bu, kurallar, zamanlanmış taramalar ve bildirimler için de geçerlidir.
- Kurallar yalnızca **öneri kuyruğuna** `Finding` ekler.
- Garanti tip düzeyinde uygulanır: `ActionExecutor` yalnızca `ApprovedCleanupPlan` kabul eder; bu tip yalnızca `UserConfirmation` ile oluşturulabilir.
- CLI'da `--yes` bayrağı açık bir kullanıcı onayı sayılır, ancak hiçbir zaman varsayılan değildir ve yapılandırma dosyasıyla kalıcı hale getirilemez.

## Sonuçlar

- "Tamamen otomatik temizlik" özelliği hiçbir zaman olmayacak.
- Toplu onay ("🟢 tümünü temizle") mümkündür, ama yine de tek bir açık kullanıcı eylemidir.
