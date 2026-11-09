import Foundation

/// Hiçbir eylemin hedefleyemeyeceği yollar (FR-CORE-05).
///
/// `ActionExecutor` her eylemden hemen önce hedef yolu buradan geçirir (#7). Kontrol, yol
/// sembolik bağlantılar ve `..` bileşenleri çözüldükten sonra yapılır; karşılaştırma büyük/küçük
/// harf ve Unicode normalizasyonundan bağımsızdır (APFS varsayılan olarak harf duyarsızdır).
///
/// Bir yol şu durumlarda reddedilir:
/// - Bir sistem dizininin kendisi veya altıysa (`/System`, `/usr` (`/usr/local` hariç), …),
/// - Korunan bir kökün kendisiyse (`~`, `~/Library`, `~/Documents`, `~/Desktop`, `/Applications`, …),
/// - Korunan herhangi bir yolu *içeriyorsa* (ör. `/Users` veya `/private`): üst dizini taşımak
///   korunan yolu da taşır,
/// - Bir `.git` dizininin kendisi veya altıysa,
/// - `/Applications` altındaki bir Apple sistem uygulamasının kendisi veya altıysa.
///
/// Bkz. docs/sdlc/02-design/architecture.md#korunan-yollar.
public struct ProtectedPaths: Sendable {
    /// Kendisi ve altındaki her şey korunan sistem dizinleri.
    static let systemSubtrees = ["/System", "/usr", "/bin", "/sbin", "/private/etc", "/private/var/db"]
    /// `systemSubtrees` içinde olup yine de hedeflenebilen alt ağaçlar.
    static let systemExceptions = ["/usr/local"]
    /// Yalnızca kendisi korunan sistem kökleri; içlerindeki tek tek öğeler önerilebilir.
    static let systemRoots = ["/", "/Applications", "/Library", "/Users", "/Volumes", "/private", "/private/var"]
    /// Ev dizinine göre, yalnızca kendisi korunan kökler.
    static let homeRoots = ["", "Library", "Documents", "Desktop"]
    /// Ev dizinine göre, kendisi ve altı korunan yollar (içlerini bozmak kütüphaneyi bozar).
    static let homeSubtrees = ["Pictures/Photos Library.photoslibrary"]

    private let subtrees: [[String]]
    private let exceptions: [[String]]
    private let roots: [[String]]
    private let applicationsDirectories: [[String]]
    private let applicationsDirectoryPaths: [String]

    /// - Parameters:
    ///   - homeDirectory: Kullanıcının ev dizini. Testlerde sahte bir dizin verilebilir.
    ///   - applicationsDirectories: Apple sistem uygulamalarının aranacağı dizinler.
    public init(
        homeDirectory: URL,
        applicationsDirectories: [URL] = [URL(fileURLWithPath: "/Applications", isDirectory: true)]
    ) {
        let home = Self.resolve(homeDirectory.path)
        let join = { (relative: String) in relative.isEmpty ? home : home + "/" + relative }

        subtrees = (Self.systemSubtrees + Self.homeSubtrees.map(join)).map(Self.normalizedComponents)
        exceptions = Self.systemExceptions.map(Self.normalizedComponents)
        let appDirs = applicationsDirectories.map { Self.resolve($0.path) }
        roots = (Self.systemRoots + Self.homeRoots.map(join) + appDirs).map(Self.normalizedComponents)
        self.applicationsDirectories = appDirs.map(Self.normalizedComponents)
        self.applicationsDirectoryPaths = appDirs
    }

    /// Gerçek kullanıcının ev dizini ile korunan yollar.
    public static func current() -> ProtectedPaths {
        ProtectedPaths(homeDirectory: FileManager.default.homeDirectoryForCurrentUser)
    }

    /// Yol korunuyorsa nedenini döndürür; hedeflenebilirse `nil`.
    public func violation(for url: URL) -> ProtectedPathViolation? {
        guard url.isFileURL else {
            return ProtectedPathViolation(url: url, resolvedPath: url.absoluteString, reason: .notFileURL)
        }
        // Hem son bileşen çözülmüş (sembolik bağlantının hedefi) hem de çözülmemiş (bağlantının
        // kendisi) hâl kontrol edilir; hangisi korunuyorsa yol reddedilir.
        let fullyResolved = Self.resolve(url.path)
        let linkItself = Self.resolve(url.path, followingFinalSymlink: false)
        for path in [fullyResolved, linkItself] {
            if let reason = reason(forResolvedPath: path) {
                return ProtectedPathViolation(url: url, resolvedPath: path, reason: reason)
            }
        }
        return nil
    }

    /// Yol korunuyorsa hata fırlatır.
    public func validate(_ url: URL) throws(ProtectedPathViolation) {
        if let violation = violation(for: url) { throw violation }
    }

    public func isProtected(_ url: URL) -> Bool {
        violation(for: url) != nil
    }

    // MARK: - Kurallar

    private func reason(forResolvedPath path: String) -> ProtectedPathViolation.Reason? {
        let components = Self.normalizedComponents(path)

        if components.contains(".git") {
            return .gitDirectory
        }
        let isException = exceptions.contains { components.starts(with: $0) }
        if !isException, let subtree = subtrees.first(where: { components.starts(with: $0) }) {
            return .protectedSubtree(Self.display(subtree))
        }
        if let root = roots.first(where: { $0 == components }) {
            return .protectedRoot(Self.display(root))
        }
        if let contained = (subtrees + roots).first(where: {
            $0.count > components.count && $0.starts(with: components)
        }) {
            return .containsProtectedPath(Self.display(contained))
        }
        if let bundleID = appleSystemAppIdentifier(containing: path, components: components) {
            return .appleSystemApp(bundleID)
        }
        return nil
    }

    /// Yol `/Applications` altındaki bir Apple sistem uygulamasının içindeyse paket kimliğini döndürür.
    ///
    /// App Store'dan kurulmuş (makbuzu olan) Apple uygulamaları — Pages, Keynote, Xcode… — kullanıcı
    /// tarafından kaldırılabilir olduğu için korunmaz.
    private func appleSystemAppIdentifier(containing path: String, components: [String]) -> String? {
        for (index, directory) in applicationsDirectories.enumerated() where components.starts(with: directory) {
            let rawComponents = Self.rawComponents(path)
            guard let appOffset = components.dropFirst(directory.count).firstIndex(where: { $0.hasSuffix(".app") })
            else { continue }
            let appPath = ([applicationsDirectoryPaths[index]] + rawComponents[directory.count...appOffset])
                .joined(separator: "/")
            let appURL = URL(fileURLWithPath: appPath, isDirectory: true)
            let contents = appURL.appendingPathComponent("Contents", isDirectory: true)
            guard
                let data = try? Data(contentsOf: contents.appendingPathComponent("Info.plist")),
                let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                let bundleID = plist["CFBundleIdentifier"] as? String,
                bundleID.lowercased().hasPrefix("com.apple.")
            else { continue }
            let receipt = contents.appendingPathComponent("_MASReceipt/receipt").path
            if FileManager.default.fileExists(atPath: receipt) { continue }
            return bundleID
        }
        return nil
    }

    // MARK: - Yol çözme

    /// Mutlak, sembolik bağlantıları ve `.`/`..` bileşenleri çözülmüş yol.
    ///
    /// Var olmayan yollar için var olan en uzun ön ek `realpath` ile çözülür, kalan bileşenler
    /// sırayla eklenir. `..`, POSIX'teki gibi *çözülmüş* üst dizine göre uygulanır.
    static func resolve(_ path: String, followingFinalSymlink: Bool = true) -> String {
        let absolute = path.hasPrefix("/") ? path : FileManager.default.currentDirectoryPath + "/" + path
        let components = absolute.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        guard let last = components.last else { return "/" }

        let parent = "/" + components.dropLast().joined(separator: "/")
        if followingFinalSymlink || last == "." || last == ".." {
            if let real = realpath(absolute) { return real }
        }
        let resolvedParent = resolve(parent)
        switch last {
        case ".": return resolvedParent
        case "..": return resolvedParent == "/" ? "/" : (resolvedParent as NSString).deletingLastPathComponent
        default: return resolvedParent == "/" ? "/" + last : resolvedParent + "/" + last
        }
    }

    private static func realpath(_ path: String) -> String? {
        guard let pointer = Darwin.realpath(path, nil) else { return nil }
        defer { free(pointer) }
        return String(cString: pointer)
    }

    private static func rawComponents(_ path: String) -> [String] {
        path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
    }

    /// Karşılaştırma için bileşenler: Unicode NFC + harf katlama.
    static func normalizedComponents(_ path: String) -> [String] {
        rawComponents(path.precomposedStringWithCanonicalMapping).map {
            $0.folding(options: [.caseInsensitive], locale: nil)
        }
    }

    private static func display(_ components: [String]) -> String {
        "/" + components.joined(separator: "/")
    }
}

/// Korunan bir yolun hedeflenmesi denemesi.
public struct ProtectedPathViolation: Error, Sendable, Hashable, CustomStringConvertible {
    public enum Reason: Sendable, Hashable {
        /// Dosya sistemi URL'i değil.
        case notFileURL
        /// Kendisi ve altı korunan bir dizinin içinde (ör. `/System`).
        case protectedSubtree(String)
        /// Korunan bir kökün kendisi (ör. `~/Documents`).
        case protectedRoot(String)
        /// Korunan bir yolu içeren üst dizin (ör. `/Users`).
        case containsProtectedPath(String)
        /// Bir `.git` dizini veya içeriği.
        case gitDirectory
        /// `/Applications` altındaki bir Apple sistem uygulaması.
        case appleSystemApp(String)
    }

    public let url: URL
    /// Sembolik bağlantılar çözüldükten sonra kontrol edilen yol.
    public let resolvedPath: String
    public let reason: Reason

    public var description: String {
        let detail =
            switch reason {
            case .notFileURL: "dosya sistemi yolu değil"
            case .protectedSubtree(let root): "korunan sistem dizini (\(root))"
            case .protectedRoot(let root): "korunan kök dizin (\(root)); yalnızca içindeki öğeler önerilebilir"
            case .containsProtectedPath(let inner): "korunan bir yolu içeriyor (\(inner))"
            case .gitDirectory: "bir .git dizini"
            case .appleSystemApp(let bundleID): "Apple sistem uygulaması (\(bundleID))"
            }
        return "Korunan yol: \(resolvedPath) — \(detail)"
    }
}
