# 07 — Bakım

## Triage

Yeni issue'lar `status: needs-triage` ile gelir. Triage sırasında: tür, area, priority ve milestone atanır; gerekirse PRD'ye bağlanır.

## Etiketler

| Grup | Etiketler |
|---|---|
| Tür | `type: feature`, `type: bug`, `type: task`, `type: docs`, `type: idea` |
| Alan | `area: core`, `area: scanner`, `area: ui`, `area: cli`, `area: uninstaller`, `area: rules`, `area: infra` |
| Öncelik | `priority: p0` (engelleyici), `priority: p1`, `priority: p2` |
| Durum | `status: needs-triage`, `status: blocked` |
| Özel | `safety` (silme güvenliğini etkiler), `good first issue` |

## Bağımlılıklar

Dependabot, GitHub Actions ve Swift paketleri için haftalık güncelleme PR'ları açar. Bu PR'lar da aynı kurallara tabidir:

- `PR Policy` iş akışı her Dependabot PR'ı için `dependencies` etiketli bir bakım issue'su açar (başlık: `Bağımlılık güncellemesi: … (PR #N)`) ve PR açıklamasına `Closes #<issue>` ekler.
- PR birleşince issue otomatik kapanır; PR birleşmeden kapanırsa issue "not planned" olarak kapatılır.
- Birleştirme kararı yine maintainer'ındır.

## Güvenlik

Silme güvenliğiyle ilgili hatalar `safety` + `priority: p0` alır ve diğer her şeyin önüne geçer. Bkz. [SECURITY.md](../../../SECURITY.md).
