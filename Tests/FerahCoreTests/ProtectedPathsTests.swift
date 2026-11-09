import Foundation
import Testing

@testable import FerahCore

/// Geçici bir sahte ev dizini ve `/Applications` dizini. Testler gerçek kullanıcı verisine dokunmaz.
private final class Fixture {
    let root: URL
    let home: URL
    let applications: URL
    let paths: ProtectedPaths

    init() throws {
        let fm = FileManager.default
        root = fm.temporaryDirectory.appendingPathComponent("ferah-protected-\(UUID().uuidString)", isDirectory: true)
        home = root.appendingPathComponent("home", isDirectory: true)
        applications = root.appendingPathComponent("Applications", isDirectory: true)
        for dir in ["Library/Caches", "Documents", "Desktop", "Pictures/Photos Library.photoslibrary/database"] {
            try fm.createDirectory(at: home.appendingPathComponent(dir), withIntermediateDirectories: true)
        }
        try fm.createDirectory(at: applications, withIntermediateDirectories: true)
        paths = ProtectedPaths(homeDirectory: home, applicationsDirectories: [applications])
    }

    deinit { try? FileManager.default.removeItem(at: root) }

    func url(_ relative: String, in base: URL? = nil) -> URL {
        URL(fileURLWithPath: (base ?? home).path + "/" + relative)
    }

    func makeDirectory(_ relative: String) throws -> URL {
        let url = self.url(relative)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    func makeFile(_ relative: String) throws -> URL {
        let url = self.url(relative)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("x".utf8).write(to: url)
        return url
    }

    @discardableResult
    func makeSymlink(_ relative: String, to destination: String) throws -> URL {
        let url = self.url(relative)
        try FileManager.default.createSymbolicLink(atPath: url.path, withDestinationPath: destination)
        return url
    }

    func makeApp(_ name: String, bundleID: String, appStoreReceipt: Bool = false) throws -> URL {
        let app = applications.appendingPathComponent(name, isDirectory: true)
        let contents = app.appendingPathComponent("Contents", isDirectory: true)
        try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        let plist = try PropertyListSerialization.data(
            fromPropertyList: ["CFBundleIdentifier": bundleID], format: .xml, options: 0)
        try plist.write(to: contents.appendingPathComponent("Info.plist"))
        if appStoreReceipt {
            let receipt = contents.appendingPathComponent("_MASReceipt", isDirectory: true)
            try FileManager.default.createDirectory(at: receipt, withIntermediateDirectories: true)
            try Data().write(to: receipt.appendingPathComponent("receipt"))
        }
        return app
    }
}

@Suite("ProtectedPaths — sistem dizinleri")
struct ProtectedSystemPathsTests {
    let paths = ProtectedPaths(homeDirectory: URL(fileURLWithPath: "/tmp/ferah-nonexistent-home"))

    @Test(
        "Sistem dizinleri ve altları reddedilir",
        arguments: [
            "/", "/System", "/System/Library/CoreServices", "/usr", "/usr/bin/ls", "/bin", "/bin/sh", "/sbin",
            "/private/etc", "/private/etc/hosts", "/private/var/db", "/private/var/db/receipts",
            "/Applications", "/Library", "/Users", "/Volumes", "/private", "/private/var",
        ])
    func systemPathsAreRejected(path: String) {
        #expect(paths.isProtected(URL(fileURLWithPath: path)))
    }

    @Test("/usr/local altı hedeflenebilir", arguments: ["/usr/local/Cellar/foo", "/usr/local/lib/node_modules"])
    func usrLocalIsAllowed(path: String) {
        #expect(paths.violation(for: URL(fileURLWithPath: path)) == nil)
    }

    @Test(
        "Sistem sembolik bağlantıları çözülür (/etc → /private/etc, /var → /private/var)",
        arguments: ["/etc", "/etc/hosts", "/var/db", "/var/db/receipts", "/tmp/../etc/passwd"])
    func systemSymlinksAreResolved(path: String) throws {
        let violation = try #require(paths.violation(for: URL(fileURLWithPath: path)))
        #expect(violation.resolvedPath.hasPrefix("/private/etc") || violation.resolvedPath.hasPrefix("/private/var/db"))
    }

    @Test(
        "`..` ile kaçış reddedilir",
        arguments: [
            "/usr/local/../bin", "/usr/local/../../System", "/Applications/../System/Library",
            "/usr/local/nonexistent/../../bin/zsh", "/tmp/a/b/../../../../usr",
        ])
    func dotDotEscapeIsRejected(path: String) {
        #expect(paths.isProtected(URL(fileURLWithPath: path)))
    }

    @Test(
        "Büyük/küçük harf varyasyonları reddedilir",
        arguments: ["/SYSTEM", "/system/library", "/USR/bin", "/Private/ETC/hosts", "/aPPLICATIONS", "/users"])
    func caseVariationsAreRejected(path: String) {
        #expect(paths.isProtected(URL(fileURLWithPath: path)))
    }

    @Test("/usr/local istisnası harf varyasyonuyla da geçerli, kaçış yine reddedilir")
    func usrLocalCaseVariation() {
        #expect(!paths.isProtected(URL(fileURLWithPath: "/usr/LOCAL/Cellar")))
        #expect(paths.isProtected(URL(fileURLWithPath: "/usr/LOCAL/../BIN")))
    }

    @Test("Dosya sistemi dışı URL reddedilir")
    func nonFileURLIsRejected() throws {
        let violation = try #require(paths.violation(for: URL(string: "https://example.com/System")!))
        #expect(violation.reason == .notFileURL)
    }

    @Test("validate korunan yolda hata fırlatır")
    func validateThrows() {
        #expect(throws: ProtectedPathViolation.self) { try paths.validate(URL(fileURLWithPath: "/System")) }
        #expect(throws: Never.self) { try paths.validate(URL(fileURLWithPath: "/usr/local/foo")) }
    }
}

@Suite("ProtectedPaths — ev dizini")
struct ProtectedHomePathsTests {
    @Test("Ev dizini kökleri reddedilir, içlerindeki öğeler önerilebilir")
    func homeRoots() throws {
        let fx = try Fixture()
        for root in ["", "Library", "Documents", "Desktop", "Library/", "Documents/."] {
            #expect(fx.paths.isProtected(fx.url(root)), "\(root)")
        }
        let violation = try #require(fx.paths.violation(for: fx.url("Library")))
        guard case .protectedRoot = violation.reason else {
            Issue.record("beklenmeyen neden: \(violation.reason)")
            return
        }

        let allowed = [
            try fx.makeFile("Documents/eski-rapor.pdf"), try fx.makeDirectory("Library/Caches/com.example"),
            try fx.makeFile("Desktop/ekran.png"), fx.url("Library/Caches"), fx.url("Downloads/big.dmg"),
        ]
        for url in allowed {
            #expect(fx.paths.violation(for: url) == nil, "\(url.path)")
        }
    }

    @Test("Ev dizinini içeren üst dizinler reddedilir")
    func ancestorsOfHome() throws {
        let fx = try Fixture()
        let violation = try #require(fx.paths.violation(for: fx.root))
        guard case .containsProtectedPath = violation.reason else {
            Issue.record("beklenmeyen neden: \(violation.reason)")
            return
        }
        #expect(fx.paths.isProtected(fx.url("..")))
        #expect(fx.paths.isProtected(fx.url("Library/Caches/../..")))
        #expect(fx.paths.isProtected(fx.url("Documents/../Library")))
    }

    @Test("Fotoğraflar arşivi ve içi reddedilir")
    func photosLibrary() throws {
        let fx = try Fixture()
        #expect(fx.paths.isProtected(fx.url("Pictures/Photos Library.photoslibrary")))
        #expect(fx.paths.isProtected(fx.url("Pictures/Photos Library.photoslibrary/database")))
        #expect(fx.paths.isProtected(fx.url("Pictures")))
        #expect(!fx.paths.isProtected(try fx.makeFile("Pictures/tatil.jpg")))
    }

    @Test("Büyük/küçük harf ve Unicode varyasyonları reddedilir")
    func caseAndUnicodeVariations() throws {
        let fx = try Fixture()
        for path in ["documents", "DESKTOP", "library", "LiBrArY/", "pictures/photos library.PHOTOSLIBRARY/x"] {
            #expect(fx.paths.isProtected(fx.url(path)), "\(path)")
        }
        // Ayrıştırılmış (NFD) "é" ile yazılmış yol, birleşik (NFC) hâliyle aynı kabul edilir.
        let nfc = try fx.makeDirectory("Café")
        let paths = ProtectedPaths(homeDirectory: nfc)
        let nfd = URL(fileURLWithPath: nfc.path.decomposedStringWithCanonicalMapping)
        #expect(paths.isProtected(nfd))
    }

    @Test("Ev dizini sembolik bağlantıyla verilse de korunur")
    func symlinkedHome() throws {
        let fx = try Fixture()
        let link = fx.root.appendingPathComponent("home-link")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: fx.home)
        let paths = ProtectedPaths(homeDirectory: link)
        #expect(paths.isProtected(fx.home))
        #expect(paths.isProtected(fx.url("Documents")))
        #expect(paths.isProtected(link))
    }
}

@Suite("ProtectedPaths — sembolik bağlantı kaçışları")
struct ProtectedSymlinkTests {
    @Test("Korunan yola işaret eden bağlantı reddedilir")
    func linkToProtected() throws {
        let fx = try Fixture()
        let toSystem = try fx.makeSymlink("Library/Caches/sistem", to: "/System")
        let toDocuments = try fx.makeSymlink("Library/Caches/belgeler", to: fx.home.path + "/Documents")
        let relative = try fx.makeSymlink("Library/Caches/göreli", to: "../../Desktop")
        for url in [toSystem, toDocuments, relative] {
            #expect(fx.paths.isProtected(url), "\(url.path)")
        }
    }

    @Test("Bağlantılı dizin üzerinden korunan alt ağaca kaçış reddedilir")
    func escapeThroughLinkedDirectory() throws {
        let fx = try Fixture()
        try fx.makeSymlink("Library/Caches/kaçış", to: "/usr")
        #expect(fx.paths.isProtected(fx.url("Library/Caches/kaçış/bin/ls")))
        #expect(fx.paths.isProtected(fx.url("Library/Caches/kaçış/local/../bin")))
        // `..` bağlantının *hedefine* göre uygulanır: /usr/.. = / (korunan kök).
        #expect(fx.paths.isProtected(fx.url("Library/Caches/kaçış/..")))
    }

    @Test("Bağlantı zinciri sonuna kadar çözülür")
    func chainedLinks() throws {
        let fx = try Fixture()
        try fx.makeSymlink("Library/Caches/a", to: fx.home.path + "/Library/Caches/b")
        try fx.makeSymlink("Library/Caches/b", to: "/private/etc")
        #expect(fx.paths.isProtected(fx.url("Library/Caches/a")))
        #expect(fx.paths.isProtected(fx.url("Library/Caches/a/hosts")))
    }

    @Test("Bağlantı yolunun kendisi korunan bir yerdeyse reddedilir")
    func linkInsideProtected() throws {
        let fx = try Fixture()
        let target = try fx.makeDirectory("Library/Caches/zararsız")
        try fx.makeSymlink("Documents/.git", to: target.path)
        #expect(fx.paths.isProtected(fx.url("Documents/.git")))
    }

    @Test("Zararsız hedefe işaret eden ya da kopuk bağlantı hedeflenebilir")
    func harmlessLinks() throws {
        let fx = try Fixture()
        let target = try fx.makeDirectory("Library/Caches/gerçek")
        let link = try fx.makeSymlink("Library/Caches/bağlantı", to: target.path)
        let dangling = try fx.makeSymlink("Library/Caches/kopuk", to: fx.root.path + "/yok")
        #expect(!fx.paths.isProtected(link))
        #expect(!fx.paths.isProtected(dangling))
    }
}

@Suite("ProtectedPaths — .git ve uygulamalar")
struct ProtectedGitAndAppTests {
    @Test("Herhangi bir .git dizini ve içi reddedilir")
    func gitDirectories() throws {
        let fx = try Fixture()
        _ = try fx.makeFile("Developer/proje/.git/HEAD")
        for path in ["Developer/proje/.git", "Developer/proje/.git/HEAD", "Developer/proje/.GIT/objects", "a/.Git"] {
            let violation = fx.paths.violation(for: fx.url(path))
            #expect(violation?.reason == .gitDirectory, "\(path)")
        }
        for path in ["Developer/proje/node_modules", "Developer/proje/.gitignore", "Developer/proje/.github"] {
            #expect(!fx.paths.isProtected(fx.url(path)), "\(path)")
        }
    }

    @Test("Apple sistem uygulaması ve içi reddedilir")
    func appleSystemApp() throws {
        let fx = try Fixture()
        let safari = try fx.makeApp("Safari.app", bundleID: "com.apple.Safari")
        #expect(fx.paths.violation(for: safari)?.reason == .appleSystemApp("com.apple.Safari"))
        #expect(fx.paths.isProtected(safari.appendingPathComponent("Contents/Info.plist")))
        #expect(fx.paths.isProtected(fx.url("safari.APP", in: fx.applications)))
        #expect(fx.paths.isProtected(fx.applications))
    }

    @Test("Üçüncü taraf ve App Store'dan kurulmuş Apple uygulamaları hedeflenebilir")
    func removableApps() throws {
        let fx = try Fixture()
        let thirdParty = try fx.makeApp("Slack.app", bundleID: "com.tinyspeck.slackmacgap")
        let pages = try fx.makeApp("Pages.app", bundleID: "com.apple.iWork.Pages", appStoreReceipt: true)
        let broken = fx.applications.appendingPathComponent("Bozuk.app")
        try FileManager.default.createDirectory(at: broken, withIntermediateDirectories: true)
        for url in [thirdParty, pages, broken] {
            #expect(fx.paths.violation(for: url) == nil, "\(url.path)")
        }
    }
}
