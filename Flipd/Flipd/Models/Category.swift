import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorHex: String
    var icon: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#4A90D9",
        icon: String = "square.stack.fill",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.createdAt = createdAt
    }
}

// MARK: - Sample Data
extension Category {
    static let samples: [Category] = [
        Category(name: "Mathematics", colorHex: "#FF6B6B", icon: "function"),
        Category(name: "History",     colorHex: "#4ECDC4", icon: "book.closed.fill"),
        Category(name: "Science",     colorHex: "#45B7D1", icon: "atom"),
        Category(name: "Languages",   colorHex: "#96CEB4", icon: "globe")
    ]
}
