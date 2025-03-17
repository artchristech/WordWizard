import Foundation
import SwiftData

@Model
class ReadingSession {
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        return endTime?.timeIntervalSince(startTime) ?? Date().timeIntervalSince(startTime)
    }
    var wordsLearned: Int
    
    init(startTime: Date = Date()) {
        self.startTime = startTime
        self.wordsLearned = 0
    }
    
    func endSession() {
        self.endTime = Date()
    }
}