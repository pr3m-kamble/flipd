import SwiftUI

struct FlashcardView: View {
    let card: Flashcard
    let flipDegrees: Double
    let dragOffset: CGSize
    let opacity: Double

    var body: some View {
        ZStack {
            // Front face
            CardFace(text: card.question, isFront: true, masteryLevel: card.masteryLevel)
                .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) < 90 ||
                         flipDegrees.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)

            // Back face
            CardFace(text: card.answer, isFront: false, masteryLevel: card.masteryLevel)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(flipDegrees.truncatingRemainder(dividingBy: 360) >= 90 &&
                         flipDegrees.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
        }
        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width) / 20))
        .opacity(opacity)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Card Face
private struct CardFace: View {
    let text: String
    let isFront: Bool
    let masteryLevel: MasteryLevel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isFront ? Color(.systemBackground) : Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(masteryColor.opacity(0.3), lineWidth: 1.5)
                )

            VStack(spacing: 12) {
                Text(isFront ? "QUESTION" : "ANSWER")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.secondary)

                Text(text)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(masteryColor)
                        .frame(width: 8, height: 8)
                    Text(masteryLevel.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(28)
        }
        .frame(width: 320, height: 420)
    }

    private var masteryColor: Color {
        switch masteryLevel {
        case .mastered:  return .green
        case .learning:  return .orange
        case .needsWork: return .red
        }
    }
}
