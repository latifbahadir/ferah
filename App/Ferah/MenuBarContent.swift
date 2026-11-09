import FerahCore
import SwiftUI

/// Menü çubuğu menüsü. Şimdilik yer tutucu; özet ve hızlı tarama v0.4'te (#24) gelecek.
struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text("Mac'in hep ferah kalsın.")

        Divider()

        Button("Ferah'ı Aç") {
            openWindow(id: MainWindow.id)
            NSApp.activate()
        }
        .keyboardShortcut("o")

        Divider()

        Button("Ferah'tan Çık") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
