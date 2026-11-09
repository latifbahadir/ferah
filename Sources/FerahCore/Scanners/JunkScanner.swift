import Foundation

/// Bir çöp kaynağını tarayıp bulgu üreten bileşen.
///
/// Tarayıcılar yalnızca okur; hiçbir dosyayı değiştirmez veya silmez (CI'daki yasaklı API
/// denetimi bunu zorunlu kılar). Uzun süren işlerde `Task.checkCancellation()` çağrılmalıdır.
public protocol JunkScanner: Sendable {
    /// Kalıcı ve benzersiz kimlik. Örn. "xcode.derivedData".
    var id: String { get }
    /// Kullanıcıya gösterilen ad. Örn. "Xcode".
    var displayName: String { get }
    func scan(_ context: ScanContext) async throws -> [Finding]
}

/// Bir taramanın ortam bilgileri. Testlerde sahte bir ev dizini ve sabit saat enjekte edilebilir.
public struct ScanContext: Sendable {
    /// Kullanıcının ev dizini. Tarayıcılar `~` yerine her zaman bunu kullanır.
    public let homeDirectory: URL
    /// Proje tabanlı tarayıcıların (node_modules, Rust target…) arayacağı kök dizinler.
    public let searchRoots: [URL]
    /// "Şu an". Yaş hesapları bunu kullanır; testlerde sabitlenebilir.
    public let now: Date

    public init(homeDirectory: URL, searchRoots: [URL]? = nil, now: Date = Date()) {
        self.homeDirectory = homeDirectory
        self.searchRoots = searchRoots ?? [homeDirectory]
        self.now = now
    }

    /// Gerçek kullanıcının ev dizini ile bağlam.
    public static func current() -> ScanContext {
        ScanContext(homeDirectory: FileManager.default.homeDirectoryForCurrentUser)
    }
}
