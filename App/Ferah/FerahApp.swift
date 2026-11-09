import FerahCore
import SwiftUI

@main
struct FerahApp: App {
    var body: some Scene {
        WindowGroup(id: MainWindow.id) {
            ContentView()
        }
        .defaultSize(width: 720, height: 480)

        MenuBarExtra(FerahInfo.name, systemImage: "wind") {
            MenuBarContent()
        }
    }
}

enum MainWindow {
    static let id = "main"
}
