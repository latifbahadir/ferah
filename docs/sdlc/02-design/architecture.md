# Mimari

## Genel bakış

```
┌──────────────────────┐   ┌──────────────────────┐
│  Ferah.app (SwiftUI) │   │  ferah (CLI)         │
│  • Ana pencere       │   │  • scan / clean      │
│  • MenuBarExtra      │   │  • history / undo    │
│  • Onay akışı        │   │  • Etkileşimli onay  │
└──────────┬───────────┘   └──────────┬───────────┘
           │                          │
           └────────────┬─────────────┘
                        ▼
┌───────────────────────────────────────────────────┐
│ FerahCore (Swift Package, UI'dan bağımsız)          │
│                                                     │
│  ScanEngine ──► [JunkScanner] ──► [Finding]             │
│                     ▲                               │
│  RuleEngine ────────┘ (yalnızca öneri üretir)       │
│                                                     │
│  CleanupPlan ──approve()──► ApprovedCleanupPlan     │
│                                   │                 │
│                                   ▼                 │
│  ActionExecutor ──► Trash / ToolCommand ──► History │
│        ▲                                            │
│  ProtectedPaths (her eylemden önce kontrol)          │
└───────────────────────────────────────────────────┘
```

## Repo yerleşimi (hedef)

```
Package.swift            # FerahCore (library) + ferah (executable)
Sources/
  FerahCore/
    Models/              # Finding, SafetyLevel, CleanupAction, ...
    Scanners/            # Xcode, NodeModules, PackageCaches, Docker, ...
    Engine/              # ScanEngine, RuleEngine
    Actions/             # CleanupPlan, ActionExecutor, History
    Safety/              # ProtectedPaths
  ferah/                 # CLI (swift-argument-parser)
Tests/
  FerahCoreTests/
App/
  Ferah.xcodeproj        # SwiftUI uygulaması, yerel FerahCore paketine bağlı
  Ferah/
```

Kök dizindeki `Package.swift` sayesinde `swift build` / `swift test` doğrudan çalışır; CI bunu kullanır.

## Temel tipler (taslak)

```swift
public enum SafetyLevel: Sendable {
    case regenerable   // 🟢 yeniden üretilebilir (önbellek, DerivedData, node_modules)
    case userFile      // 🟡 kullanıcı verisi (büyük dosyalar, DMG'ler)
    case application   // 🔴 uygulama ve kalıntıları, simulator'lar
}

public struct Finding: Identifiable, Sendable {
    public let id: UUID
    public let scannerID: String
    public let title: String
    public let paths: [URL]
    public let sizeBytes: Int64
    public let safety: SafetyLevel
    public let reason: String          // "147 gündür commit yok, npm install ile yeniden oluşur"
    public let confidence: Double      // 0...1
    public let action: CleanupAction
}

public enum CleanupAction: Sendable {
    case moveToTrash([URL])
    case toolCommand(ToolCommand)      // ör. xcrun simctl delete unavailable, docker image prune
    case uninstallApp(AppBundle)       // uygulama + kalıntılar (+ brew cask)
}

public protocol JunkScanner: Sendable {
    var id: String { get }
    var displayName: String { get }
    func scan(_ context: ScanContext) async throws -> [Finding]
}
```

## Onay garantisi (tip düzeyinde)

`ActionExecutor` yalnızca `ApprovedCleanupPlan` kabul eder. `ApprovedCleanupPlan`'ın başlatıcısı dışarıya kapalıdır; tek yol `CleanupPlan.approve(_ confirmation: UserConfirmation)` çağrısıdır ve `UserConfirmation` yalnızca arayüzdeki onay eyleminden veya CLI'daki etkileşimli onaydan üretilir. **`RuleEngine`'in `ActionExecutor`'a erişimi yoktur**; yalnızca `Finding` üretir. Bkz. [ADR-0002](adr/0002-approval-red-line.md).

## Eylem yürütme

- Dosyalar `FileManager.trashItem(at:resultingItemURL:)` ile Çöp Sepeti'ne taşınır; sonuç URL'i geçmişe yazılır (geri alma için).
- Araç komutları beyaz listededir (`ToolCommand` enum'u); serbest kabuk komutu çalıştırılmaz.
- `FileManager.removeItem` ve `rm` kod tabanında kullanılmaz (lint kuralı ile denetlenir). Bkz. [ADR-0003](adr/0003-trash-first.md).

## Korunan yollar

Aşağıdakiler ve altları hiçbir eylemde hedeflenemez; kontrol `ActionExecutor` içinde, her eylemden hemen önce, sembolik bağlantılar çözüldükten sonra yapılır:

- `/System`, `/usr` (`/usr/local` hariç), `/bin`, `/sbin`, `/private/etc`, `/private/var/db`
- `/Applications` altındaki Apple sistem uygulamaları
- `~` (ev dizininin kendisi), `~/Library` (kendisi), `~/Documents`, `~/Desktop` ve `~/Pictures/Photos Library.photoslibrary` (kendileri; yalnızca içlerindeki tek tek dosyalar önerilebilir)
- Herhangi bir `.git` dizini

## Arka plan

- Menü çubuğu: ana uygulamadaki `MenuBarExtra`; oturum açılışı için `SMAppService.mainApp`.
- Downloads izleme: FSEvents.
- Bildirimler: `UserNotifications`. Bildirimler yalnızca uygulamayı açar; bildirimden doğrudan silme yapılmaz.

## Veri

Geçmiş ve kurallar `~/Library/Application Support/Ferah/` altında yerel JSON dosyalarında tutulur. Ağ erişimi yoktur.
