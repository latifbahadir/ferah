/// Bir bulgunun silinmesinin ne kadar güvenli olduğunu belirtir.
///
/// Seviye arttıkça (``regenerable`` → ``application``) risk ve gereken inceleme düzeyi artar.
/// Bkz. docs/pdlc/02-definition/prd.md (FR-CORE-01).
public enum SafetyLevel: Int, Sendable, Hashable, CaseIterable, Comparable, Codable {
    /// 🟢 Yeniden üretilebilir: önbellekler, DerivedData, `node_modules`. Toplu onaylanabilir.
    case regenerable = 0
    /// 🟡 Kullanıcı verisi: büyük dosyalar, DMG'ler, kopyalar. Tek tek incelenmeli.
    case userFile = 1
    /// 🔴 Uygulama veya sistem bileşeni: uygulamalar ve kalıntıları, simulator'lar.
    case application = 2

    public static func < (lhs: SafetyLevel, rhs: SafetyLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var emoji: String {
        switch self {
        case .regenerable: "🟢"
        case .userFile: "🟡"
        case .application: "🔴"
        }
    }

    public var displayName: String {
        switch self {
        case .regenerable: "Yeniden üretilebilir"
        case .userFile: "Kullanıcı dosyası"
        case .application: "Uygulama / sistem"
        }
    }

    /// `true` ise bulgular toplu onayla değil, tek tek gözden geçirilerek onaylanmalıdır.
    public var requiresIndividualReview: Bool {
        self != .regenerable
    }
}
