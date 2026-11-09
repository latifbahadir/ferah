import Testing

@testable import FerahCore

@Suite("FerahInfo")
struct FerahInfoTests {
    @Test("Sürüm semantik sürümleme biçiminde")
    func versionIsSemantic() {
        let parts = FerahInfo.version.split(separator: ".")
        #expect(parts.count == 3)
        #expect(parts.allSatisfy { Int($0) != nil })
    }

    @Test("Ürün adı Ferah")
    func nameIsFerah() {
        #expect(FerahInfo.name == "Ferah")
    }
}
