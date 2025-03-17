import Foundation
import SwiftData

@Model
class VocabularyWord {
    var word: String
    var definition: String
    var dateAdded: Date
    var learned: Bool
    var timesReviewed: Int
    var notes: String?
    
    init(word: String, definition: String, notes: String? = nil) {
        self.word = word
        self.definition = definition
        self.dateAdded = Date()
        self.learned = false
        self.timesReviewed = 0
        self.notes = notes
    }
}