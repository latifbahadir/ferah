import ArgumentParser
import FerahCore

@main
struct FerahCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ferah",
        abstract: "\(FerahInfo.tagline) Geliştirici odaklı macOS temizlik asistanı.",
        discussion: """
        Ferah hiçbir şeyi onayın olmadan silmez. Alt komutlar (scan, clean, history, undo) \
        sonraki sürümlerde eklenecek.
        """,
        version: FerahInfo.version
    )
}
