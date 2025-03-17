import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ReadingView()
                .tabItem {
                    Label("Reading", systemImage: "book.fill")
                }
                .tag(0)
            
            LearningView()
                .tabItem {
                    Label("Learning", systemImage: "graduationcap.fill")
                }
                .tag(1)
            
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}