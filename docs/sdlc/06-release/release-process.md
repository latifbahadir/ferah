# Release Süreci

- **Sürümleme:** SemVer. `v0.x` döneminde küçük sürümler milestone'lara karşılık gelir.
- **Etiket:** `vX.Y.Z` etiketi `main` üzerinde, maintainer tarafından atılır.

## Adımlar

1. Milestone'daki issue'lar kapandı (veya taşındı).
2. `chore/<issue>-release-vX.Y.Z` branch'inde `CHANGELOG.md` ve sürüm numarası güncellenir → PR → merge.
3. Maintainer `main` üzerinde `vX.Y.Z` etiketini atar.
4. Release iş akışı (v1.0 milestone'unda kurulacak): derleme → imzalama → notarization → DMG → GitHub Release.
5. Sürüm notu `docs/pdlc/04-launch/release-notes/vX.Y.Z.md` olarak eklenir.

v1.0'a kadar imzasız yerel derleme (`xcodebuild` / Xcode) yeterlidir.
