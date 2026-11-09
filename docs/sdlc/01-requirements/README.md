# 01 — Gereksinim → Issue

## Issue türleri

| Şablon | Etiket | Ne zaman |
|---|---|---|
| Özellik | `type: feature` | Kullanıcıya görünen yeni yetenek |
| Hata | `type: bug` | Beklenmeyen davranış (silme ile ilgiliyse ayrıca `safety`) |
| Görev | `type: task` | Altyapı, refactor, doküman, CI |
| Yeni tarayıcı | `type: feature` + `area: scanner` | Yeni bir çöp kaynağı desteği |

Her issue: bir **milestone**, bir **area** etiketi ve bir **priority** etiketi taşır. Gereksinimden geliyorsa PRD ID'sini (`FR-DEV-02` gibi) belirtir.

## Definition of Ready

Bir issue üzerinde çalışmaya başlamadan önce:

- [ ] Amaç ve kabul kriterleri yazılı
- [ ] İlgili PRD ID'si (varsa) belirtilmiş
- [ ] Milestone, area ve priority atanmış
- [ ] Silme davranışı içeriyorsa güvenlik seviyesi ve eylem türü belirlenmiş
- [ ] Mimari karar gerekiyorsa ADR açılmış veya mevcut ADR'ye bağlanmış
