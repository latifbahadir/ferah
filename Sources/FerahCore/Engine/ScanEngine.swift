import Foundation

/// Tarayıcıları paralel çalıştırıp sonuçlarını birleştirir.
///
/// - Bir tarayıcının hatası taramayı durdurmaz; ``ScanReport/failures`` içinde raporlanır.
/// - Tarama iptal edilirse `CancellationError` fırlatılır.
public struct ScanEngine: Sendable {
    public let scanners: [any JunkScanner]

    public init(scanners: [any JunkScanner]) {
        self.scanners = scanners
    }

    public func scan(_ context: ScanContext) async throws -> ScanReport {
        let started = context.now
        let outcomes = await withTaskGroup(of: ScannerOutcome.self) { group in
            for scanner in scanners {
                group.addTask {
                    do {
                        try Task.checkCancellation()
                        return .success(try await scanner.scan(context))
                    } catch is CancellationError {
                        return .cancelled
                    } catch {
                        return .failure(
                            ScannerFailure(
                                scannerID: scanner.id,
                                scannerName: scanner.displayName,
                                message: String(describing: error)
                            ))
                    }
                }
            }
            var collected: [ScannerOutcome] = []
            for await outcome in group {
                collected.append(outcome)
            }
            return collected
        }

        try Task.checkCancellation()

        var findings: [Finding] = []
        var failures: [ScannerFailure] = []
        for outcome in outcomes {
            switch outcome {
            case .success(let items): findings.append(contentsOf: items)
            case .failure(let failure): failures.append(failure)
            case .cancelled: throw CancellationError()
            }
        }

        findings.sort { lhs, rhs in
            lhs.sizeBytes != rhs.sizeBytes ? lhs.sizeBytes > rhs.sizeBytes : lhs.title < rhs.title
        }
        failures.sort { $0.scannerID < $1.scannerID }
        return ScanReport(startedAt: started, findings: findings, failures: failures)
    }
}

private enum ScannerOutcome: Sendable {
    case success([Finding])
    case failure(ScannerFailure)
    case cancelled
}

/// Taranamayan bir kaynak. Arayüzde "taranamadı" olarak gösterilir.
public struct ScannerFailure: Sendable, Hashable {
    public let scannerID: String
    public let scannerName: String
    public let message: String
}

/// Bir taramanın sonucu.
public struct ScanReport: Sendable {
    public let startedAt: Date
    /// Boyuta göre büyükten küçüğe sıralı bulgular.
    public let findings: [Finding]
    public let failures: [ScannerFailure]

    /// Tüm bulguların toplam boyutu (bayt).
    public var totalBytes: Int64 {
        findings.reduce(0) { $0 + $1.sizeBytes }
    }

    /// Güvenlik seviyesine göre gruplanmış bulgular.
    public func findings(for safety: SafetyLevel) -> [Finding] {
        findings.filter { $0.safety == safety }
    }
}
