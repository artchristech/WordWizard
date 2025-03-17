import Foundation
import SwiftData

/// Service for managing reading sessions
class ReadingSessionService {
    static let shared = ReadingSessionService()
    
    private init() {}
    
    /// Calculate total reading time from all sessions
    /// - Parameter sessions: Array of reading sessions
    /// - Returns: Total time spent reading in seconds
    func calculateTotalReadingTime(_ sessions: [ReadingSession]) -> TimeInterval {
        return sessions.reduce(0) { $0 + $1.duration }
    }
    
    /// Calculate average reading session length
    /// - Parameter sessions: Array of reading sessions
    /// - Returns: Average session duration in seconds
    func calculateAverageSessionLength(_ sessions: [ReadingSession]) -> TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        let total = calculateTotalReadingTime(sessions)
        return total / Double(sessions.count)
    }
    
    /// Get reading sessions grouped by day
    /// - Parameters:
    ///   - sessions: Array of reading sessions
    ///   - calendar: Calendar to use for date calculations
    /// - Returns: Dictionary with dates as keys and total duration for that day as values
    func sessionsGroupedByDay(_ sessions: [ReadingSession], calendar: Calendar = .current) -> [Date: TimeInterval] {
        var result: [Date: TimeInterval] = [:]
        
        for session in sessions {
            if let date = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: session.startTime)) {
                result[date, default: 0] += session.duration
            }
        }
        
        return result
    }
    
    /// Format a time interval as a readable string
    /// - Parameter interval: Time interval in seconds
    /// - Returns: Formatted string (e.g. "1h 30m" or "45m")
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Get reading streak (consecutive days with reading activity)
    /// - Parameter sessions: Array of reading sessions
    /// - Returns: Number of consecutive days with reading activity
    func calculateReadingStreak(_ sessions: [ReadingSession]) -> Int {
        let calendar = Calendar.current
        let sessionsByDay = sessionsGroupedByDay(sessions)
        let sortedDates = sessionsByDay.keys.sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var streak = 1
        var lastDate = sortedDates[0]
        
        for i in 1..<sortedDates.count {
            let currentDate = sortedDates[i]
            let daysBetween = calendar.dateComponents([.day], from: currentDate, to: lastDate).day ?? 0
            
            if daysBetween == 1 {
                streak += 1
                lastDate = currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}