import Foundation
import Testing

@testable import FerahCore

private struct StubScanner: JunkScanner {
    let id: String
    var displayName: String { id }
    let result: @Sendable (ScanContext) async throws -> [Finding]

    func scan(_ context: ScanContext) async throws -> [Finding] {
        try await result(context)
    }
}

private struct StubError: Error, CustomStringConvertible {
    var description: String { "erişim reddedildi" }
}

/// İki tarayıcının aynı anda çalıştığını kanıtlamak için: her biri diğerinin başlamasını bekler.
private actor Rendezvous {
    private var arrived = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func arriveAndWait(count: Int) async {
        arrived += 1
        if arrived >= count {
            waiters.forEach { $0.resume() }
            waiters.removeAll()
            return
        }
        await withCheckedContinuation { waiters.append($0) }
    }
}

@Suite("ScanEngine")
struct ScanEngineTests {
    let context = ScanContext(
        homeDirectory: URL(fileURLWithPath: "/tmp/fake-home"), now: Date(timeIntervalSince1970: 0))

    @Test("Tüm tarayıcıların bulgularını birleştirir ve boyuta göre sıralar")
    func aggregatesAndSorts() async throws {
        let engine = ScanEngine(scanners: [
            StubScanner(id: "a") { _ in [.sample(title: "küçük", size: 10), .sample(title: "büyük", size: 900)] },
            StubScanner(id: "b") { _ in [.sample(title: "orta", size: 500)] },
        ])

        let report = try await engine.scan(context)

        #expect(report.findings.map(\.title) == ["büyük", "orta", "küçük"])
        #expect(report.totalBytes == 1_410)
        #expect(report.failures.isEmpty)
        #expect(report.startedAt == context.now)
    }

    @Test("Bir tarayıcının hatası taramayı durdurmaz")
    func failureIsIsolated() async throws {
        let engine = ScanEngine(scanners: [
            StubScanner(id: "bozuk") { _ in throw StubError() },
            StubScanner(id: "sağlam") { _ in [.sample()] },
        ])

        let report = try await engine.scan(context)

        #expect(report.findings.count == 1)
        #expect(
            report.failures == [ScannerFailure(scannerID: "bozuk", scannerName: "bozuk", message: "erişim reddedildi")])
    }

    @Test("Bağlam tarayıcılara olduğu gibi iletilir")
    func passesContext() async throws {
        let engine = ScanEngine(scanners: [
            StubScanner(id: "a") { ctx in [.sample(title: ctx.homeDirectory.lastPathComponent)] }
        ])

        let report = try await engine.scan(context)

        #expect(report.findings.first?.title == "fake-home")
    }

    @Test("Tarayıcılar paralel çalışır", .timeLimit(.minutes(1)))
    func runsConcurrently() async throws {
        let rendezvous = Rendezvous()
        let engine = ScanEngine(scanners: [
            StubScanner(id: "a") { _ in
                await rendezvous.arriveAndWait(count: 2)
                return [.sample(title: "a")]
            },
            StubScanner(id: "b") { _ in
                await rendezvous.arriveAndWait(count: 2)
                return [.sample(title: "b")]
            },
        ])

        let report = try await engine.scan(context)

        #expect(Set(report.findings.map(\.title)) == ["a", "b"])
    }

    @Test("İptal edilen tarama CancellationError fırlatır")
    func cancellation() async {
        let engine = ScanEngine(scanners: [
            StubScanner(id: "yavaş") { _ in
                try await Task.sleep(for: .seconds(30))
                return []
            }
        ])
        let context = self.context

        let task = Task { try await engine.scan(context) }
        task.cancel()

        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }

    @Test("Bulgular güvenlik seviyesine göre süzülebilir")
    func groupsBySafety() async throws {
        let engine = ScanEngine(scanners: [
            StubScanner(id: "a") { _ in
                [.sample(title: "önbellek", safety: .regenerable), .sample(title: "video", safety: .userFile)]
            }
        ])

        let report = try await engine.scan(context)

        #expect(report.findings(for: .userFile).map(\.title) == ["video"])
        #expect(report.findings(for: .application).isEmpty)
    }
}
