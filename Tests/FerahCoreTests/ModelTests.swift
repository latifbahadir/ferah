import Foundation
import Testing

@testable import FerahCore

@Suite("SafetyLevel")
struct SafetyLevelTests {
    @Test("Seviyeler riske göre sıralı")
    func ordering() {
        #expect(SafetyLevel.regenerable < .userFile)
        #expect(SafetyLevel.userFile < .application)
        #expect(SafetyLevel.allCases.sorted() == [.regenerable, .userFile, .application])
    }

    @Test("Yalnızca yeniden üretilebilirler toplu onaylanabilir")
    func individualReview() {
        #expect(!SafetyLevel.regenerable.requiresIndividualReview)
        #expect(SafetyLevel.userFile.requiresIndividualReview)
        #expect(SafetyLevel.application.requiresIndividualReview)
    }
}

@Suite("Finding")
struct FindingTests {
    @Test(
        "Güven skoru 0...1 aralığına sıkıştırılır", arguments: [(-0.5, 0.0), (0.4, 0.4), (1.7, 1.0), (Double.nan, 0.0)])
    func confidenceIsClamped(input: Double, expected: Double) {
        #expect(Finding.sample(confidence: input).confidence == expected)
    }

    @Test("Negatif boyut sıfıra çekilir")
    func negativeSize() {
        #expect(Finding.sample(size: -10).sizeBytes == 0)
    }

    @Test("Çöp Sepeti eylemleri geri alınabilir, araç komutları alınamaz")
    func reversibility() {
        #expect(CleanupAction.moveToTrash([]).isReversible)
        #expect(!CleanupAction.toolCommand(.dockerImagePrune).isReversible)
    }
}

@Suite("ScanContext")
struct ScanContextTests {
    @Test("Arama kökü verilmezse ev dizini kullanılır")
    func defaultSearchRoots() {
        let home = URL(fileURLWithPath: "/tmp/fake-home")
        #expect(ScanContext(homeDirectory: home).searchRoots == [home])
    }
}

extension Finding {
    static func sample(
        scannerID: String = "test",
        title: String = "örnek",
        size: Int64 = 1_000,
        safety: SafetyLevel = .regenerable,
        confidence: Double = 0.9
    ) -> Finding {
        Finding(
            scannerID: scannerID,
            title: title,
            paths: [URL(fileURLWithPath: "/tmp/\(title)")],
            sizeBytes: size,
            safety: safety,
            reason: "test",
            confidence: confidence,
            action: .moveToTrash([URL(fileURLWithPath: "/tmp/\(title)")])
        )
    }
}
