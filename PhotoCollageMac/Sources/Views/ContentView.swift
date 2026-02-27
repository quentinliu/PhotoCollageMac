import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigationState: NavigationState
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            mainContent
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private var sidebarContent: some View {
        List(selection: $navigationState.selectedTab) {
            Section("导航") {
                Label("首页", systemImage: "house.fill")
                    .tag(0)
                
                Label("创建", systemImage: "plus.circle.fill")
                    .tag(1)
                
                Label("模板", systemImage: "sparkles")
                    .tag(2)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180)
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch navigationState.selectedTab {
        case 0:
            HomeView()
        case 1:
            CreateView(initialLayout: navigationState.quickStartLayout)
        case 2:
            TemplatesView()
        default:
            HomeView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationState.shared)
}
