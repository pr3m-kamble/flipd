import SwiftUI

// MARK: - Root
struct HomeView: View {
    @StateObject private var cardListVM = CardListViewModel()
    @StateObject private var progressVM = ProgressViewModel()

    var body: some View {
        TabView {
            DecksView(viewModel: cardListVM)
                .tabItem { Label("Decks", systemImage: "square.stack.fill") }

            StatsView(viewModel: progressVM)
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .onAppear { progressVM.reload() }
    }
}

// MARK: - Decks List
struct DecksView: View {
    @ObservedObject var viewModel: CardListViewModel
    @State private var isAddingCategory = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.categories.isEmpty {
                    EmptyDecksView { isAddingCategory = true }
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            NavigationLink {
                                CardListView(viewModel: viewModel, category: category)
                            } label: {
                                CategoryRow(
                                    category: category,
                                    cardCount: viewModel.cards(for: category.id).count
                                )
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteCategory(id: category.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Flipd 📚")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { isAddingCategory = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingCategory) {
                AddCategorySheet(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Card List (per category)
struct CardListView: View {
    @ObservedObject var viewModel: CardListViewModel
    let category: Category
    @State private var isAddingCard = false
    @State private var cardToEdit: Flashcard?
    @State private var isStudying = false

    var cards: [Flashcard] { viewModel.cards(for: category.id) }

    var body: some View {
        List {
            if cards.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary)
                    Text("No cards yet")
                        .font(.headline)
                    Text("Tap + to add your first card")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(cards) { card in
                    CardRow(card: card)
                        .contentShape(Rectangle())
                        .onTapGesture { cardToEdit = card }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteCard(id: card.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if !cards.isEmpty {
                        Button { isStudying = true } label: {
                            Label("Study", systemImage: "play.fill")
                        }
                    }
                    Button { isAddingCard = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingCard) {
            AddCardSheet(viewModel: viewModel, categoryID: category.id)
        }
        .sheet(item: $cardToEdit) { card in
            EditCardSheet(viewModel: viewModel, card: card)
        }
        .sheet(isPresented: $isStudying) {
            StudyView(viewModel: StudyViewModel(
                cards: cards,
                categoryID: category.id,
                onUpdateCards: { updated in
                    updated.forEach { viewModel.updateCard($0) }
                }
            ))
        }
    }
}

// MARK: - Card Row
struct CardRow: View {
    let card: Flashcard

    var masteryColor: Color {
        switch card.masteryLevel {
        case .mastered:  return .green
        case .learning:  return .orange
        case .needsWork: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(card.question)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Circle()
                    .fill(masteryColor)
                    .frame(width: 8, height: 8)
            }
            Text(card.answer)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Card Sheet
struct AddCardSheet: View {
    @ObservedObject var viewModel: CardListViewModel
    let categoryID: UUID
    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var answer = ""

    var isValid: Bool {
        !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !answer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField("Enter the question", text: $question, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Answer") {
                    TextField("Enter the answer", text: $answer, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addCard(
                            question: question.trimmingCharacters(in: .whitespaces),
                            answer: answer.trimmingCharacters(in: .whitespaces),
                            categoryID: categoryID
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Edit Card Sheet
struct EditCardSheet: View {
    @ObservedObject var viewModel: CardListViewModel
    let card: Flashcard
    @Environment(\.dismiss) private var dismiss
    @State private var question: String
    @State private var answer: String

    init(viewModel: CardListViewModel, card: Flashcard) {
        self.viewModel = viewModel
        self.card = card
        _question = State(initialValue: card.question)
        _answer   = State(initialValue: card.answer)
    }

    var isValid: Bool {
        !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !answer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField("Question", text: $question, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Answer") {
                    TextField("Answer", text: $answer, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = card
                        updated.question = question.trimmingCharacters(in: .whitespaces)
                        updated.answer   = answer.trimmingCharacters(in: .whitespaces)
                        viewModel.updateCard(updated)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

// MARK: - Category Row
struct CategoryRow: View {
    let category: Category
    let cardCount: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color(hex: category.colorHex))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(category.name).font(.headline)
                Text("\(cardCount) card\(cardCount == 1 ? "" : "s")")
                    .font(.subheadline).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State
struct EmptyDecksView: View {
    let onAdd: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            Text("No Decks Yet")
                .font(.title2.bold())
            Text("Create a category to start adding flashcards")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Create First Deck", action: onAdd)
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
        }
        .padding(40)
    }
}

// MARK: - Add Category Sheet
struct AddCategorySheet: View {
    @ObservedObject var viewModel: CardListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor = "#4A90D9"
    @State private var selectedIcon = "square.stack.fill"

    private let colorOptions = ["#FF6B6B","#4ECDC4","#45B7D1","#96CEB4","#FFEAA7","#DDA0DD","#98D8C8"]
    private let iconOptions  = ["square.stack.fill","book.closed.fill","atom","globe","brain","pencil","star.fill"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(selectedColor == hex ? Circle().stroke(Color.primary, lineWidth: 2) : nil)
                                .onTapGesture { selectedColor = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .frame(width: 36, height: 36)
                                .background(selectedIcon == icon ? Color(.systemFill) : .clear)
                                .cornerRadius(8)
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addCategory(name: name, colorHex: selectedColor, icon: selectedIcon)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}


// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("colorScheme") private var colorScheme: String = "system"
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $colorScheme) {
                        Label("System", systemImage: "circle.lefthalf.filled").tag("system")
                        Label("Light",  systemImage: "sun.max.fill").tag("light")
                        Label("Dark",   systemImage: "moon.fill").tag("dark")
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Delete All Data")
                        }
                    }
                } footer: {
                    Text("This will permanently delete all categories, cards, and study history.")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Delete All Data?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) {
                    StorageService.shared.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
}
