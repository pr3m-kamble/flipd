import SwiftUI
import Foundation

struct Flashcard: Identifiable, Codable, Equatable {
    let id: UUID
    var question: String
    var answer: String
    var categoryID: UUID
    var isFlipped: Bool = false
    var reviewCount: Int = 0
    var correctCount: Int = 0
    var lastReviewedAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        categoryID: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.categoryID = categoryID
        self.createdAt = createdAt
    }

    var accuracy: Double {
        guard reviewCount > 0 else { return 0 }
        return Double(correctCount) / Double(reviewCount) * 100
    }

    var masteryLevel: MasteryLevel {
        switch accuracy {
        case 80...: return .mastered
        case 50..<80: return .learning
        default: return .needsWork
        }
    }
}

enum MasteryLevel: String, Codable {
    case mastered = "Mastered"
    case learning = "Learning"
    case needsWork = "Needs Work"

    var color: String {
        switch self {
        case .mastered: return "green"
        case .learning: return "orange"
        case .needsWork: return "red"
        }
    }
}
