import Foundation

/// Bir tarayıcının bulduğu ve temizlenmesini önerdiği öğe.
///
/// Her bulgu *neden* önerildiğini açıklar (FR-CORE-01). Bir bulgu tek başına hiçbir eylemi
/// tetiklemez; yalnızca öneridir.
public struct Finding: Identifiable, Sendable, Hashable {
    public let id: UUID
    /// Bulguyu üreten tarayıcının kimliği (``JunkScanner/id``).
    public let scannerID: String
    /// Kısa başlık. Örn. "old-landing/node_modules".
    public let title: String
    /// Etkilenen yollar.
    public let paths: [URL]
    /// Toplam boyut (bayt).
    public let sizeBytes: Int64
    public let safety: SafetyLevel
    /// İnsan okunur gerekçe. Örn. "147 gündür commit yok, npm install ile yeniden oluşur".
    public let reason: String
    /// Önerinin doğruluğuna güven, `0...1` aralığına sıkıştırılır.
    public let confidence: Double
    public let action: CleanupAction

    public init(
        id: UUID = UUID(),
        scannerID: String,
        title: String,
        paths: [URL],
        sizeBytes: Int64,
        safety: SafetyLevel,
        reason: String,
        confidence: Double,
        action: CleanupAction
    ) {
        self.id = id
        self.scannerID = scannerID
        self.title = title
        self.paths = paths
        self.sizeBytes = max(0, sizeBytes)
        self.safety = safety
        self.reason = reason
        self.confidence = confidence.isNaN ? 0 : min(1, max(0, confidence))
        self.action = action
    }

    /// Boyutun kullanıcıya gösterilecek biçimi. Örn. "1,2 GB".
    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
    }
}
