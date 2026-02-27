import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigationState: NavigationState
    @State private var recentCollages: [CollageHistory] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                welcomeSection
                quickStartSection
                recentSection
            }
            .padding(40)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("欢迎使用")
                .font(.system(size: 36, weight: .bold))
            
            Text("快速创建精美的照片拼图")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快速开始")
                .font(.headline)
            
            HStack(spacing: 16) {
                QuickStartButton(
                    icon: "square.grid.2x2",
                    title: "2×2",
                    color: .blue,
                    action: { navigationState.navigateToCreate(with: .grid2x2) }
                )
                
                QuickStartButton(
                    icon: "square.grid.3x3",
                    title: "3×3",
                    color: .purple,
                    action: { navigationState.navigateToCreate(with: .grid3x3) }
                )
                
                QuickStartButton(
                    icon: "rectangle.split.1x2",
                    title: "长图",
                    color: .orange,
                    action: { navigationState.navigateToCreate(with: .longImage) }
                )
                
                QuickStartButton(
                    icon: "rectangle.grid.2x3",
                    title: "2×3",
                    color: .green,
                    action: { navigationState.navigateToCreate(with: .grid2x3) }
                )
                
                QuickStartButton(
                    icon: "rectangle.grid.3x2",
                    title: "3×2",
                    color: .pink,
                    action: { navigationState.navigateToCreate(with: .grid3x2) }
                )
            }
        }
    }
    
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("最近作品")
                    .font(.headline)
                Spacer()
                if !recentCollages.isEmpty {
                    Button("查看全部") {}
                        .foregroundColor(.accentColor)
                }
            }
            
            if recentCollages.isEmpty {
                emptyState
            } else {
                recentCollagesGrid
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无作品")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("点击「创建」开始制作您的第一个拼图")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var recentCollagesGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(recentCollages) { collage in
                RecentCollageCard(collage: collage)
            }
        }
    }
}

struct QuickStartButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .frame(width: 100, height: 80)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct RecentCollageCard: View {
    let collage: CollageHistory
    
    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                
                Text(collage.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct CollageHistory: Identifiable {
    let id = UUID()
    let date: Date
    let image: NSImage?
}

#Preview {
    HomeView()
        .environmentObject(NavigationState.shared)
}
