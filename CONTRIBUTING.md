# Katkı Rehberi

Ferah'a katkı yapmak istediğin için teşekkürler! Süreç kısaca:

1. **Issue ile başla.** Her iş bir issue'dur. Yoksa uygun şablonla aç (özellik, hata, görev, yeni tarayıcı).
2. **Branch aç.** `main`'den, issue numarasıyla: `feat/12-xcode-tarayici`, `fix/34-trash-hatasi`.
   Ayrıntı: [docs/sdlc/03-implementation/branching-and-commits.md](docs/sdlc/03-implementation/branching-and-commits.md)
3. **Küçük, odaklı değişiklik yap.** Bir PR = bir issue.
4. **Test et.** `swift test` geçmeli. Silme davranışını etkileyen her değişiklik test içermeli.
5. **PR aç.** Açıklamada `Closes #<issue>` zorunludur — yoksa `PR Policy / issue-link` kontrolü başarısız olur.
6. **Review ve birleştirme.** PR'lar yalnızca maintainer (@latifbahadir) tarafından, CI yeşilken birleştirilir. Birleştirme yöntemi: squash.

## Kırmızı çizgiler

- Kullanıcı onayı olmadan hiçbir dosya silinmez/taşınmaz — kural motoru dahil.
- Doğrudan `rm`/`removeItem` yok; yalnızca `ActionExecutor` üzerinden Çöp Sepeti'ne taşıma veya aracın resmi temizlik komutu.
- Korunan yollar listesi ([mimari](docs/sdlc/02-design/architecture.md#korunan-yollar)) zayıflatılamaz.

## Yeni tarayıcı eklemek

Tarayıcılar (`Scanner`) eklenti gibi tasarlanmıştır. "Yeni tarayıcı" issue şablonunu kullan ve [mimari dokümanındaki](docs/sdlc/02-design/architecture.md) sözleşmeyi izle.
