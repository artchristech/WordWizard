import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Query var vocabularyWords: [VocabularyWord]
    @Query var readingSessions: [ReadingSession]
    
    @State private var selectedTimeframe: Timeframe = .week
    
    var totalReadingTime: TimeInterval {
        readingSessions.reduce(0) { $0 + $1.duration }
    }
    
    var totalWordsLearned: Int {
        vocabularyWords.filter { $0.learned }.count
    }
    
    var totalWordsSaved: Int {
        vocabularyWords.count
    }
    
    var progress: Double {
        totalWordsSaved > 0 ? Double(totalWordsLearned) / Double(totalWordsSaved) : 0
    }
    
    var readingSessionsByDay: [DateValue] {
        let calendar = Calendar.current
        let sessions = readingSessions
        
        // Group sessions by day
        var result: [Date: TimeInterval] = [:]
        
        for session in sessions {
            if let date = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: session.startTime)) {
                result[date, default: 0] += session.duration
            }
        }
        
        // Convert to array of DateValue
        let dateValues = result.map { DateValue(date: $0.key, value: $0.value / 60) } // Convert to minutes
        
        // Filter based on selected timeframe
        let filteredValues = dateValues.filter { dateValue in
            switch selectedTimeframe {
            case .week:
                return dateValue.date > Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            case .month:
                return dateValue.date > Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            case .year:
                return dateValue.date > Calendar.current.date(byAdding: .year, value: -1, to: Date())!
            case .all:
                return true
            }
        }
        
        return filteredValues.sorted { $0.date < $1.date }
    }
    
    var wordsByDay: [DateValue] {
        let calendar = Calendar.current
        let words = vocabularyWords
        
        // Group words by day added
        var result: [Date: Int] = [:]
        
        for word in words {
            if let date = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: word.dateAdded)) {
                result[date, default: 0] += 1
            }
        }
        
        // Convert to array of DateValue
        let dateValues = result.map { DateValue(date: $0.key, value: Double($0.value)) }
        
        // Filter based on selected timeframe
        let filteredValues = dateValues.filter { dateValue in
            switch selectedTimeframe {
            case .week:
                return dateValue.date > Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            case .month:
                return dateValue.date > Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            case .year:
                return dateValue.date > Calendar.current.date(byAdding: .year, value: -1, to: Date())!
            case .all:
                return true
            }
        }
        
        return filteredValues.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary stats
                    statsView
                    
                    // Timeframe selector
                    timeframeSelector
                    
                    // Reading time chart
                    readingTimeChartView
                    
                    // Words learned chart
                    wordsLearnedChartView
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
    
    var statsView: some View {
        VStack(spacing: 16) {
            HStack {
                StatCard(
                    title: "Reading Time",
                    value: formatTimeInterval(totalReadingTime),
                    icon: "clock.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Words Saved",
                    value: "\(totalWordsSaved)",
                    icon: "bookmark.fill",
                    color: .orange
                )
            }
            
            HStack {
                StatCard(
                    title: "Words Learned",
                    value: "\(totalWordsLearned)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Learning Progress",
                    value: "\(Int(progress * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
    }
    
    var timeframeSelector: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            Text("Week").tag(Timeframe.week)
            Text("Month").tag(Timeframe.month)
            Text("Year").tag(Timeframe.year)
            Text("All Time").tag(Timeframe.all)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical)
    }
    
    var readingTimeChartView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reading Time")
                .font(.headline)
            
            if readingSessionsByDay.isEmpty {
                Text("No reading data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(readingSessionsByDay, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Minutes", item.value)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(formatDate(date))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    var wordsLearnedChartView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Words Added")
                .font(.headline)
            
            if wordsByDay.isEmpty {
                Text("No vocabulary data for this period")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart(wordsByDay, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date, unit: .day),
                        y: .value("Words", item.value)
                    )
                    .foregroundStyle(.orange.gradient)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(formatDate(date))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // Helper methods
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .bold()
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DateValue: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

enum Timeframe {
    case week, month, year, all
}

#Preview {
    ProgressView()
}