# Branch ve Commit Kuralları

## Branch'ler

- `main`: korumalı, her zaman derlenebilir. Doğrudan push yasak.
- Çalışma branch'i: `<tür>/<issue-no>-<kisa-ad>`
  - `feat/12-xcode-tarayici`
  - `fix/34-trash-geri-alma`
  - `docs/5-mimari-guncelleme`
  - `chore/3-ci-kurulumu`
- Branch'ler birleştirildikten sonra otomatik silinir.

## Commit mesajları — Conventional Commits

```
<tür>(<kapsam>): <kısa açıklama>

[gövde]

Refs #<issue>
```

Türler: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `perf`.
Kapsamlar: `core`, `scanner`, `ui`, `cli`, `uninstaller`, `rules`, `infra`.

Örnek: `feat(scanner): Xcode DerivedData tarayıcısı`

Squash merge kullanıldığı için **PR başlığı** da aynı biçimde yazılır; `main`'deki commit mesajı PR başlığından gelir.
