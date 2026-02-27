import SwiftUI

@main
struct PhotoCollageMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var navigationState = NavigationState.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationState)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.automatic)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("Collage") {
                Button("New Collage") {
                    navigationState.selectedTab = 1
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Divider()
                
                Button("Export...") {
                    navigationState.selectedTab = 1
                }
                .keyboardShortcut("e", modifiers: .command)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureAppearance()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func configureAppearance() {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}

@MainActor
class NavigationState: ObservableObject {
    static let shared = NavigationState()
    
    @Published var selectedTab = 0
    @Published var quickStartLayout: CollageLayout?
    
    private init() {}
    
    func navigateToCreate(with layout: CollageLayout) {
        quickStartLayout = layout
        selectedTab = 1
    }
}
