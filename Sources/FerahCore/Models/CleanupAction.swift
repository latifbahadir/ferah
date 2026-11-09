import Foundation

/// Bir bulgu onaylandığında yapılacak eylem.
///
/// Bu tip yalnızca *ne yapılacağını* tarif eder; hiçbir şeyi kendisi çalıştırmaz.
/// Yürütme yalnızca onaylı bir planla `ActionExecutor` üzerinden yapılır (ADR-0002, ADR-0003).
public enum CleanupAction: Sendable, Hashable {
    /// Yolları Çöp Sepeti'ne taşı (geri alınabilir).
    case moveToTrash([URL])
    /// Beyaz listedeki bir aracın resmi temizlik komutunu çalıştır (çoğunlukla geri alınamaz).
    case toolCommand(ToolCommand)
    /// Uygulamayı kalıntılarıyla birlikte kaldır.
    case uninstallApp(AppBundle)

    /// Eylemin Çöp Sepeti'nden geri alınıp alınamayacağı.
    public var isReversible: Bool {
        switch self {
        case .moveToTrash, .uninstallApp: true
        case .toolCommand: false
        }
    }
}

/// Çalıştırılmasına izin verilen araç komutları.
///
/// Serbest kabuk komutu yoktur; her komut burada adıyla tanımlanır. Argümanlar ve
/// yürütme `ActionExecutor` içinde sabittir (#7).
public enum ToolCommand: String, Sendable, Hashable, CaseIterable, Codable {
    /// `xcrun simctl delete unavailable`
    case simctlDeleteUnavailable
    /// `docker image prune`
    case dockerImagePrune
    /// `docker container prune`
    case dockerContainerPrune
    /// `docker builder prune`
    case dockerBuilderPrune
    /// `brew cleanup`
    case brewCleanup

    public var displayName: String {
        switch self {
        case .simctlDeleteUnavailable: "Kullanılamayan simulator'ları sil"
        case .dockerImagePrune: "Kullanılmayan Docker imajlarını temizle"
        case .dockerContainerPrune: "Durmuş Docker container'larını temizle"
        case .dockerBuilderPrune: "Docker build önbelleğini temizle"
        case .brewCleanup: "Homebrew önbelleğini temizle"
        }
    }
}

/// Kaldırılacak bir uygulama paketi. Kalıntı eşleştirme ayrıntıları #20/#21 ile genişler.
public struct AppBundle: Sendable, Hashable {
    public let url: URL
    public let bundleIdentifier: String
    public let name: String
    /// Uygulamayla birlikte kaldırılacak kalıntı yolları.
    public let leftovers: [URL]

    public init(url: URL, bundleIdentifier: String, name: String, leftovers: [URL] = []) {
        self.url = url
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.leftovers = leftovers
    }
}
