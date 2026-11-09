# SDLC — Yazılım Geliştirme Yaşam Döngüsü

SDLC, bir issue'nun koddan sürüme nasıl ilerlediğini tanımlar. Ürün tarafı için [../pdlc](../pdlc/README.md).

```
Issue ─► Tasarım ─► Branch ─► Geliştirme ─► Test ─► PR ─► Review ─► Merge (maintainer) ─► Release ─► Bakım
 01        02          03         03           04      05      05            05               06         07
```

| Aşama | Klasör | İçerik |
|---|---|---|
| 01 Gereksinim | [01-requirements](01-requirements/) | Issue türleri, Definition of Ready |
| 02 Tasarım | [02-design](02-design/) | [Mimari](02-design/architecture.md), [ADR'ler](02-design/adr/) |
| 03 Geliştirme | [03-implementation](03-implementation/) | [Branch & commit](03-implementation/branching-and-commits.md), [kod standartları](03-implementation/coding-standards.md) |
| 04 Test | [04-testing](04-testing/) | [Test stratejisi](04-testing/test-strategy.md) |
| 05 Review | [05-review](05-review/) | [PR süreci & Definition of Done](05-review/pr-process.md) |
| 06 Release | [06-release](06-release/) | [Release süreci](06-release/release-process.md) |
| 07 Bakım | [07-maintenance](07-maintenance/) | Triage, etiketler, bağımlılıklar |

## Değişmez kurallar

1. `main` korumalıdır. **Doğrudan commit/push yasaktır** (admin dahil).
2. Her iş bir issue'dur. **Her PR tek bir issue'yu kapatır** (`Closes #N`), bu CI tarafından zorunlu tutulur.
3. PR'lar **yalnızca maintainer'ın kararıyla** birleşir. Auto-merge kapalıdır.
4. Birleştirme için CI yeşil ve tüm review konuşmaları çözülmüş olmalıdır.
5. Birleştirme yöntemi: **squash**. Geçmiş doğrusal tutulur.
