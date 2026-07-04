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
                                HStack(spacing: 6) {
                                    ForEach(card.buttons.prefix(3)) { button in
                                        Text(button.value, format: .number)
                                            .font(.caption.weight(.semibold))
                                            .lineLimit(1)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(.green.opacity(0.22), in: Capsule())
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
