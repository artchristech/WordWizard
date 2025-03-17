import SwiftUI
import SwiftData

struct LearningView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabularyWord.dateAdded, order: .reverse) var vocabularyWords: [VocabularyWord]
    @State private var selectedWord: VocabularyWord?
    @State private var showingEditSheet = false
    @State private var searchText = ""
    @State private var showLearnedWords = false
    
    var filteredWords: [VocabularyWord] {
        vocabularyWords.filter { word in
            let matchesSearch = searchText.isEmpty || 
                word.word.localizedCaseInsensitiveContains(searchText) ||
                (word.definition.localizedCaseInsensitiveContains(searchText)) ||
                (word.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesLearnedFilter = showLearnedWords ? true : !word.learned
            
            return matchesSearch && matchesLearnedFilter
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filter controls
                HStack {
                    Toggle("Show Learned", isOn: $showLearnedWords)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    Spacer()
                    
                    Text("\(filteredWords.count) words")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Words list
                List {
                    ForEach(filteredWords) { word in
                        VocabularyWordRow(word: word)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedWord = word
                                showingEditSheet = true
                            }
                    }
                    .onDelete(perform: deleteWords)
                }
                .listStyle(InsetGroupedListStyle())
                .searchable(text: $searchText, prompt: "Search words")
            }
            .navigationTitle("Learning")
            .sheet(isPresented: $showingEditSheet, onDismiss: {
                selectedWord = nil
            }) {
                if let word = selectedWord {
                    EditWordView(word: word)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func deleteWords(at offsets: IndexSet) {
        for index in offsets {
            let word = filteredWords[index]
            modelContext.delete(word)
        }
    }
}

struct VocabularyWordRow: View {
    let word: VocabularyWord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(word.word)
                    .font(.headline)
                
                Spacer()
                
                if word.learned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            Text(word.definition)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let notes = word.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Text("Added \(formattedDate(word.dateAdded))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct EditWordView: View {
    @Environment(\.dismiss) private var dismiss
    
    let word: VocabularyWord
    @State private var notes: String
    @State private var learned: Bool
    
    init(word: VocabularyWord) {
        self.word = word
        _notes = State(initialValue: word.notes ?? "")
        _learned = State(initialValue: word.learned)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Word Details")) {
                    Text(word.word)
                        .font(.headline)
                    
                    Text(word.definition)
                        .font(.body)
                }
                
                Section(header: Text("Your Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Toggle("Learned", isOn: $learned)
                }
                
                Section {
                    Button("Review Word") {
                        word.timesReviewed += 1
                        word.notes = notes
                        word.learned = learned
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                    .bold()
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("Reviewed \(word.timesReviewed) times")
                        Spacer()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Save changes
                        word.notes = notes
                        word.learned = learned
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    LearningView()
}