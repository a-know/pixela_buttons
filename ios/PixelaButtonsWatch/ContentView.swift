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
                            if let feedback = syncStore.recordFeedback(for: card) {
                                RecordFeedbackView(feedback: feedback)
                                    .transition(.scale(scale: 0.95).combined(with: .opacity))
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

private struct RecordFeedbackView: View {
    let feedback: WatchRecordFeedback

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: feedback.isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.caption.weight(.semibold))
            Text(feedback.message)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(feedback.isSuccess ? Color.green : Color.red)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView()
}
