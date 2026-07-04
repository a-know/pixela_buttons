import SwiftUI

struct ContentView: View {
    @StateObject private var syncStore = WatchSyncStore.shared

    var body: some View {
        NavigationStack {
            Group {
                if syncStore.cards.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.green)

                        Text("Pixela Buttons")
                            .font(.headline)

                        Text("Waiting for cards")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                } else {
                    List(syncStore.cards) { card in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                if !card.emoji.isEmpty {
                                    Text(card.emoji)
                                }
                                Text(card.displayName)
                                    .font(.headline)
                            }
                            Text(card.graphId)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            if !card.buttons.isEmpty {
                                HStack {
                                    ForEach(card.buttons.prefix(3)) { button in
                                        Text(button.value, format: .number)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(.green.opacity(0.18), in: Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.carousel)
                }
            }
            .navigationTitle("Buttons")
        }
    }
}

#Preview {
    ContentView()
}
