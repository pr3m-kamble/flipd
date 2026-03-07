import Foundation

protocol StorageServiceProtocol {
    func saveCards(_ cards: [Flashcard])
    func loadCards() -> [Flashcard]
    func saveCategories(_ categories: [Category])
    func loadCategories() -> [Category]
    func saveSessions(_ sessions: [StudySession])
    func loadSessions() -> [StudySession]
    func deleteAllData()
}

final class StorageService: StorageServiceProtocol {

    static let shared = StorageService()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let cards      = "flipd.cards"
        static let categories = "flipd.categories"
        static let sessions   = "flipd.sessions"
    }

    private init() {}

    // MARK: - Cards
    func saveCards(_ cards: [Flashcard]) {
        save(cards, forKey: Keys.cards)
    }

    func loadCards() -> [Flashcard] {
        load([Flashcard].self, forKey: Keys.cards) ?? []
    }

    // MARK: - Categories
    func saveCategories(_ categories: [Category]) {
        save(categories, forKey: Keys.categories)
    }

    func loadCategories() -> [Category] {
        load([Category].self, forKey: Keys.categories) ?? Category.samples
    }

    // MARK: - Sessions
    func saveSessions(_ sessions: [StudySession]) {
        save(sessions, forKey: Keys.sessions)
    }

    func loadSessions() -> [StudySession] {
        load([StudySession].self, forKey: Keys.sessions) ?? []
    }

    // MARK: - Nuke
    func deleteAllData() {
        UserDefaults.standard.removeObject(forKey: Keys.cards)
        UserDefaults.standard.removeObject(forKey: Keys.categories)
        UserDefaults.standard.removeObject(forKey: Keys.sessions)
    }

    // MARK: - Generic Helpers
    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}
