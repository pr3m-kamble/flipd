import Foundation
import Combine
import SwiftUI

@MainActor
final class StudyViewModel: ObservableObject {

    // MARK: - Published State
    @Published var currentIndex: Int = 0
    @Published var isFlipped: Bool = false
    @Published var flipDegrees: Double = 0
    @Published var dragOffset: CGSize = .zero
    @Published var cardOpacity: Double = 1
    @Published var isSessionComplete: Bool = false
    @Published var session: StudySession

    // MARK: - Private
    private var deck: [Flashcard]
    private let storage: StorageServiceProtocol
    private var onUpdateCards: (([Flashcard]) -> Void)?

    // MARK: - Init
    init(
        cards: [Flashcard],
        categoryID: UUID,
        storage: StorageServiceProtocol = StorageService.shared,
        onUpdateCards: (([Flashcard]) -> Void)? = nil
    ) {
        self.deck = cards.shuffled()
        self.session = StudySession(categoryID: categoryID, totalCards: cards.count)
        self.storage = storage
        self.onUpdateCards = onUpdateCards
    }

    // MARK: - Computed
    var currentCard: Flashcard? {
        guard currentIndex < deck.count else { return nil }
        return deck[currentIndex]
    }

    var progress: Double {
        guard !deck.isEmpty else { return 0 }
        return Double(currentIndex) / Double(deck.count)
    }

    var remainingCount: Int { max(0, deck.count - currentIndex) }

    // MARK: - Flip
    func flipCard() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            flipDegrees += 180
            isFlipped.toggle()
        }
    }

    func resetFlip() {
        if isFlipped {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                flipDegrees = flipDegrees.truncatingRemainder(dividingBy: 360) == 0
                    ? flipDegrees
                    : flipDegrees + (180 - flipDegrees.truncatingRemainder(dividingBy: 180))
                isFlipped = false
            }
        }
    }

    // MARK: - Swipe
    func updateDrag(_ translation: CGSize) {
        dragOffset = translation
    }

    func endDrag(_ translation: CGSize, screenWidth: CGFloat) {
        let threshold = screenWidth * 0.35

        if translation.width > threshold {
            swipe(correct: true)
        } else if translation.width < -threshold {
            swipe(correct: false)
        } else {
            withAnimation(.spring()) { dragOffset = .zero }
        }
    }

    private func swipe(correct: Bool) {
        guard currentIndex < deck.count else { return }

        let direction: CGFloat = correct ? 1 : -1

        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            dragOffset = CGSize(width: direction * 500, height: 0)
            cardOpacity = 0
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            self.recordAnswer(correct: correct)
            self.dragOffset = .zero
            self.cardOpacity = 1
            self.isFlipped = false
            self.flipDegrees = 0
            self.currentIndex += 1

            if self.currentIndex >= self.deck.count {
                self.finishSession()
            }
        }
    }

    private func recordAnswer(correct: Bool) {
        deck[currentIndex].reviewCount += 1
        deck[currentIndex].lastReviewedAt = Date()
        if correct {
            deck[currentIndex].correctCount += 1
            session.correctCount += 1
        } else {
            session.incorrectCount += 1
        }
        onUpdateCards?(deck)
    }

    private func finishSession() {
        session.endedAt = Date()
        isSessionComplete = true
        var sessions = storage.loadSessions()
        sessions.append(session)
        storage.saveSessions(sessions)
    }

    // MARK: - Restart
    func restart() {
        deck = deck.shuffled()
        currentIndex = 0
        isFlipped = false
        flipDegrees = 0
        dragOffset = .zero
        isSessionComplete = false
        session = StudySession(categoryID: session.categoryID, totalCards: deck.count)
    }
}
