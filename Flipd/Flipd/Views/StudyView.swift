import SwiftUI

struct StudyView: View {
    @StateObject var viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if viewModel.isSessionComplete {
                    SessionCompleteView(viewModel: viewModel)
                } else if let card = viewModel.currentCard {
                    VStack(spacing: 24) {
                        // Progress bar
                        StudyProgressBar(progress: viewModel.progress)
                            .padding(.horizontal)

                        Text("\(viewModel.remainingCount) cards left")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        // Card
                        FlashcardView(
                            card: card,
                            flipDegrees: viewModel.flipDegrees,
                            dragOffset: viewModel.dragOffset,
                            opacity: viewModel.cardOpacity
                        )
                        .onTapGesture { viewModel.flipCard() }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    viewModel.updateDrag(value.translation)
                                }
                                .onEnded { value in
                                    viewModel.endDrag(
                                        value.translation,
                                        screenWidth: UIScreen.main.bounds.width
                                    )
                                }
                        )

                        Spacer()

                        // Action hints
                        SwipeHintRow()
                            .padding(.bottom, 8)

                        // Buttons
                        HStack(spacing: 40) {
                            CircleButton(icon: "xmark", color: .red) {
                                viewModel.endDrag(CGSize(width: -500, height: 0),
                                                 screenWidth: UIScreen.main.bounds.width)
                            }
                            CircleButton(icon: "arrow.left.arrow.right", color: .blue) {
                                viewModel.flipCard()
                            }
                            CircleButton(icon: "checkmark", color: .green) {
                                viewModel.endDrag(CGSize(width: 500, height: 0),
                                                 screenWidth: UIScreen.main.bounds.width)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                } else {
                    Text("No cards in this deck")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Study")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct StudyProgressBar: View {
    let progress: Double
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemFill)).frame(height: 6)
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: geo.size.width * progress, height: 6)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: 6)
    }
}

private struct SwipeHintRow: View {
    var body: some View {
        HStack {
            Label("Skip", systemImage: "arrow.left")
                .font(.caption).foregroundColor(.red)
            Spacer()
            Text("Tap to flip")
                .font(.caption).foregroundColor(.secondary)
            Spacer()
            Label("Got it", systemImage: "arrow.right")
                .font(.caption).foregroundColor(.green)
        }
        .padding(.horizontal, 40)
    }
}

private struct CircleButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.12))
                .clipShape(Circle())
        }
    }
}

// MARK: - Session Complete
struct SessionCompleteView: View {
    @ObservedObject var viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Session Complete!")
                .font(.title.bold())

            VStack(spacing: 12) {
                StatRow(label: "Correct",  value: "\(viewModel.session.correctCount)",   color: .green)
                StatRow(label: "Incorrect", value: "\(viewModel.session.incorrectCount)", color: .red)
                StatRow(label: "Accuracy", value: String(format: "%.0f%%", viewModel.session.accuracy), color: .blue)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)

            HStack(spacing: 16) {
                Button("Study Again") { viewModel.restart() }
                    .buttonStyle(.bordered)
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

private struct StatRow: View {
    let label: String; let value: String; let color: Color
    var body: some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold).foregroundColor(color)
        }
        .padding(.horizontal)
    }
}
