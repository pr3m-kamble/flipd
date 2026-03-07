
import Foundation
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {

    // MARK: - Published State
    @Published var sessions: [StudySession] = []
    @Published var stats: ProgressStats = .empty

    private let storage: StorageServiceProtocol
    private var cards: [Flashcard] = []

    init(storage: StorageServiceProtocol = StorageService.shared) {
        self.storage = storage
        reload()
    }

    // MARK: - Public
    func reload() {
        sessions = storage.loadSessions().sorted { $0.startedAt > $1.startedAt }
        cards    = storage.loadCards()
        stats    = computeStats()
    }

    func sessions(for categoryID: UUID) -> [StudySession] {
        sessions.filter { $0.categoryID == categoryID }
    }

    func recentSessions(limit: Int = 5) -> [StudySession] {
        Array(sessions.prefix(limit))
    }

    // MARK: - Private
    private func computeStats() -> ProgressStats {
        let mastered   = cards.filter { $0.masteryLevel == .mastered }.count
        let learning   = cards.filter { $0.masteryLevel == .learning }.count
        let needsWork  = cards.filter { $0.masteryLevel == .needsWork }.count

        let avgAccuracy = sessions.isEmpty ? 0.0
            : sessions.map(\.accuracy).reduce(0, +) / Double(sessions.count)

        return ProgressStats(
            totalCards: cards.count,
            masteredCards: mastered,
            learningCards: learning,
            needsWorkCards: needsWork,
            totalSessions: sessions.count,
            averageAccuracy: avgAccuracy,
            streakDays: computeStreak()
        )
    }

    private func computeStreak() -> Int {
        guard !sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let dates = Set(sessions.compactMap { s in
            calendar.startOfDay(for: s.startedAt)
        }).sorted(by: >)

        var streak = 0
        var expected = calendar.startOfDay(for: Date())

        for date in dates {
            if date == expected {
                streak += 1
                expected = calendar.date(byAdding: .day, value: -1, to: expected)!
            } else {
                break
            }
        }
        return streak
    }
}

// MARK: - Empty State
extension ProgressStats {
    static let empty = ProgressStats(
        totalCards: 0,
        masteredCards: 0,
        learningCards: 0,
        needsWorkCards: 0,
        totalSessions: 0,
        averageAccuracy: 0,
        streakDays: 0
    )
}
