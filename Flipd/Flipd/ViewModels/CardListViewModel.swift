import Foundation
import Combine

@MainActor
final class CardListViewModel: ObservableObject {

    // MARK: - Published State
    @Published var cards: [Flashcard] = []
    @Published var categories: [Category] = []
    @Published var selectedCategoryID: UUID?
    @Published var searchText: String = ""
    @Published var isShowingAddCard: Bool = false
    @Published var cardToEdit: Flashcard?

    // MARK: - Dependencies
    private let storage: StorageServiceProtocol

    init(storage: StorageServiceProtocol = StorageService.shared) {
        self.storage = storage
        load()
    }

    // MARK: - Computed
    var filteredCards: [Flashcard] {
        cards.filter { card in
            let matchesCategory = selectedCategoryID == nil || card.categoryID == selectedCategoryID
            let matchesSearch   = searchText.isEmpty ||
                card.question.localizedCaseInsensitiveContains(searchText) ||
                card.answer.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    func cards(for categoryID: UUID) -> [Flashcard] {
        cards.filter { $0.categoryID == categoryID }
    }

    func category(for id: UUID) -> Category? {
        categories.first { $0.id == id }
    }

    // MARK: - Intents
    func addCard(question: String, answer: String, categoryID: UUID) {
        let card = Flashcard(question: question, answer: answer, categoryID: categoryID)
        cards.append(card)
        persist()
    }

    func updateCard(_ updated: Flashcard) {
        guard let index = cards.firstIndex(where: { $0.id == updated.id }) else { return }
        cards[index] = updated
        persist()
    }

    func deleteCard(id: UUID) {
        cards.removeAll { $0.id == id }
        persist()
    }

    func deleteCards(at offsets: IndexSet, in list: [Flashcard]) {
        let idsToDelete = offsets.map { list[$0].id }
        cards.removeAll { idsToDelete.contains($0.id) }
        persist()
    }

    func addCategory(name: String, colorHex: String, icon: String) {
        let category = Category(name: name, colorHex: colorHex, icon: icon)
        categories.append(category)
        persist()
    }

    func deleteCategory(id: UUID) {
        categories.removeAll { $0.id == id }
        cards.removeAll { $0.categoryID == id }
        persist()
    }

    // MARK: - Persistence
    private func load() {
        cards      = storage.loadCards()
        categories = storage.loadCategories()
    }

    private func persist() {
        storage.saveCards(cards)
        storage.saveCategories(categories)
    }
}
