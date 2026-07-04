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
                            Text(syncStore.todayText(for: card))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !card.buttons.isEmpty {
                                HStack(spacing: 6) {
                                    ForEach(card.buttons.prefix(3)) { button in
                                        Button {
                                            Task {
                                                await syncStore.record(card: card, button: button)
                                            }
                                        } label: {
                                            if syncStore.isRecording(card: card, button: button) {
                                                ProgressView()
                                                    .controlSize(.mini)
                                            } else {
                                                Text(WatchSyncStore.formatted(button.value))
                                                    .font(.caption.weight(.semibold))
                                                    .lineLimit(1)
                                            }
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.green)
                                        .controlSize(.small)
                                        .disabled(syncStore.recordingButtonId != nil)
                                    }
                                }
                            }
                            if let recordMessage = syncStore.recordMessage(for: card) {
                                Text(recordMessage)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.carousel)
                }
            }
            .navigationTitle("Buttons")
            .onAppear {
                syncStore.refreshTodayValues()
            }
        }
    }
}

#Preview {
    ContentView()
}
