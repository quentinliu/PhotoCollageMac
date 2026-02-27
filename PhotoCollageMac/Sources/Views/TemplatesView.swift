import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var navigationState: NavigationState
    
    let columns = [
        GridItem(.adaptive(minimum: 180), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                templateGrid
            }
            .padding(40)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("模板")
                .font(.system(size: 36, weight: .bold))
            
            Text("选择模板快速开始")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    private var templateGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            TemplateCard(
                title: "2×2 网格",
                icon: "square.grid.2x2",
                color: .blue,
                layout: .grid2x2
            )
            
            TemplateCard(
                title: "3×3 网格",
                icon: "square.grid.3x3",
                color: .purple,
                layout: .grid3x3
            )
            
            TemplateCard(
                title: "4×4 网格",
                icon: "square.grid.4x4",
                color: .green,
                layout: .grid4x4
            )
            
            TemplateCard(
                title: "2×3 网格",
                icon: "rectangle.grid.2x3",
                color: .orange,
                layout: .grid2x3
            )
            
            TemplateCard(
                title: "3×2 网格",
                icon: "rectangle.grid.3x2",
                color: .pink,
                layout: .grid3x2
            )
            
            TemplateCard(
                title: "1×3 横排",
                icon: "rectangle.split.1x3",
                color: .cyan,
                layout: .grid1x3
            )
            
            TemplateCard(
                title: "3×1 竖排",
                icon: "rectangle.split.3x1",
                color: .indigo,
                layout: .grid3x1
            )
            
            TemplateCard(
                title: "长图",
                icon: "rectangle.split.1x2",
                color: .teal,
                layout: .longImage
            )
        }
    }
}

struct TemplateCard: View {
    let title: String
    let icon: String
    let color: Color
    let layout: CollageLayout
    
    var body: some View {
        Button(action: {
            NavigationState.shared.navigateToCreate(with: layout)
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(layout.maxPhotos) 张照片")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TemplatesView()
        .environmentObject(NavigationState.shared)
}
