# PR Süreci

1. PR, şablonla açılır ve açıklamada `Closes #<issue>` bulunur.
2. Otomatik kontroller:
   - `PR Policy / issue-link`: PR bir issue'ya bağlı mı?
   - `CI / build-and-test`: derleme ve testler
3. Review: maintainer kodu inceler; konuşmaların hepsi çözülmelidir.
4. Birleştirme: **yalnızca maintainer**, squash merge ile. Auto-merge kullanılmaz. Ajanlar (ör. Claude) PR açabilir ama asla birleştiremez.

## Definition of Done

- [ ] Issue'daki kabul kriterleri karşılandı
- [ ] Testler eklendi/güncellendi ve CI yeşil
- [ ] Silme davranışı etkilendiyse güvenlik testleri var, onay akışı ve korunan yollar korunuyor
- [ ] Gerekiyorsa doküman / ADR / CHANGELOG güncellendi
- [ ] PR tek bir issue'ya odaklı, ilgisiz değişiklik yok
