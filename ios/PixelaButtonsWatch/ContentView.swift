import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.green)

                Text("Pixela Buttons")
                    .font(.headline)

                Text("Ready to record")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding()
            .navigationTitle("Buttons")
        }
    }
}

#Preview {
    ContentView()
}
