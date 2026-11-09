import FerahCore
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wind")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.tint)

            Text(verbatim: FerahInfo.name)
                .font(.largeTitle.bold())

            Text("Mac'in hep ferah kalsın.")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Tarama özellikleri yakında geliyor.")
                .font(.callout)
                .foregroundStyle(.tertiary)
                .padding(.top, 8)

            Text("Sürüm \(FerahInfo.version)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .frame(minWidth: 480, minHeight: 320)
    }
}

#Preview {
    ContentView()
}
