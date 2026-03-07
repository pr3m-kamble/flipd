
import Foundation

struct StudySession: Identifiable, Codable {
    let id: UUID
    let categoryID: UUID
    var totalCards: Int
    var correctCount: Int
    var incorrectCount: Int
    var startedAt: Date
    var endedAt: Date?

    init(
        id: UUID = UUID(),
        categoryID: UUID,
        totalCards: Int,
        startedAt: Date = Date()
    ) {
        self.id = id
        self.categoryID = categoryID
        self.totalCards = totalCards
        self.correctCount = 0
        self.incorrectCount = 0
        self.startedAt = startedAt
    }

    var accuracy: Double {
        let answered = correctCount + incorrectCount
        guard answered > 0 else { return 0 }
        return Double(correctCount) / Double(answered) * 100
    }

    var duration: TimeInterval? {
        guard let ended = endedAt else { return nil }
        return ended.timeIntervalSince(startedAt)
    }

    var isComplete: Bool { endedAt != nil }
}

struct ProgressStats {
    let totalCards: Int
    let masteredCards: Int
    let learningCards: Int
    let needsWorkCards: Int
    let totalSessions: Int
    let averageAccuracy: Double
    let streakDays: Int

    var masteryPercentage: Double {
        guard totalCards > 0 else { return 0 }
        return Double(masteredCards) / Double(totalCards) * 100
    }
}
