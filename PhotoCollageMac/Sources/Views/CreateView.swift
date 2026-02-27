import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct CreateView: View {
    @State private var selectedLayout: CollageLayout = .grid3x3
    let initialLayout: CollageLayout?
    @State private var photos: [PhotoItem] = []
    @State private var config = CollageConfiguration()
    @State private var generatedImage: NSImage?
    @State private var isGenerating = false
    @EnvironmentObject var navigationState: NavigationState
    
    init(initialLayout: CollageLayout? = nil) {
        self.initialLayout = initialLayout
    }
    
    var body: some View {
        HSplitView {
            settingsPanel
                .frame(minWidth: 280, maxWidth: 320)
            
            VStack {
                previewSection
                actionButtons
            }
            .padding()
        }
        .onAppear {
            applyInitialLayout()
        }
    }
    
    // MARK: - Settings Panel
    
    private var settingsPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                layoutSection
                photoSection
                spacingSection
                cornerRadiusSection
                backgroundSection
            }
            .padding(20)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var layoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("布局")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 8) {
                ForEach(CollageLayout.allCases.filter { $0 != .freeform }) { layout in
                    LayoutButton(
                        layout: layout,
                        isSelected: selectedLayout == layout
                    ) {
                        if selectedLayout != layout {
                            selectedLayout = layout
                            config = CollageConfiguration(layout: layout)
                            photos = []
                        }
                    }
                }
            }
        }
    }
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("照片")
                    .font(.headline)
                Spacer()
                Text("\(photos.count)/\(selectedLayout.maxPhotos)")
                    .foregroundColor(.secondary)
            }
            
            Button(action: { selectPhotos() }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text(photos.isEmpty ? "选择照片" : "更换照片")
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.accentColor.opacity(0.1))
                .foregroundColor(.accentColor)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            if !photos.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 4) {
                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                        ZStack(alignment: .topTrailing) {
                            Image(nsImage: photo.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(4)
                            
                            Button(action: {
                                photos.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .offset(x: 4, y: -4)
                        }
                    }
                }
            }
        }
    }
    
    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("间距")
                    .font(.headline)
                Spacer()
                Text("\(Int(config.spacing)) 像素")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Slider(value: $config.spacing, in: 0...20, step: 1)
            
            HStack(spacing: 8) {
                ForEach([0, 4, 8, 12], id: \.self) { value in
                    Button(value == 0 ? "无" : "\(value)") {
                        config.spacing = CGFloat(value)
                    }
                    .buttonStyle(.bordered)
                    .tint(config.spacing == CGFloat(value) ? .accentColor : .gray)
                }
            }
        }
    }
    
    private var cornerRadiusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("圆角")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { config.cornerRadius > 0 },
                    set: { newValue in
                        config.cornerRadius = newValue ? max(config.cornerRadius, 8) : 0
                    }
                ))
                .labelsHidden()
            }
            
            if config.cornerRadius > 0 {
                Slider(value: $config.cornerRadius, in: 0...20, step: 1)
                
                HStack(spacing: 8) {
                    ForEach([0, 4, 8, 12], id: \.self) { value in
                        Button(value == 0 ? "无" : "\(value)") {
                            config.cornerRadius = CGFloat(value)
                        }
                        .buttonStyle(.bordered)
                        .tint(config.cornerRadius == CGFloat(value) ? .accentColor : .gray)
                    }
                }
            }
        }
    }
    
    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("背景颜色")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                colorButton(color: NSColor.white, isSelected: isColorSelected(NSColor.white))
                colorButton(color: NSColor.black, isSelected: isColorSelected(NSColor.black))
                colorButton(color: NSColor.gray, isSelected: isColorSelected(NSColor.gray))
                colorButton(color: NSColor.red, isSelected: isColorSelected(NSColor.red))
                colorButton(color: NSColor.orange, isSelected: isColorSelected(NSColor.orange))
                colorButton(color: NSColor.yellow, isSelected: isColorSelected(NSColor.yellow))
                colorButton(color: NSColor.green, isSelected: isColorSelected(NSColor.green))
                colorButton(color: NSColor.blue, isSelected: isColorSelected(NSColor.blue))
                colorButton(color: NSColor.purple, isSelected: isColorSelected(NSColor.purple))
            }
            
            HStack(spacing: 8) {
                gradientButton(colors: [NSColor.red, NSColor.orange], isSelected: isGradientSelected([NSColor.red, NSColor.orange]))
                gradientButton(colors: [NSColor.blue, NSColor.purple], isSelected: isGradientSelected([NSColor.blue, NSColor.purple]))
                gradientButton(colors: [NSColor.green, NSColor.blue], isSelected: isGradientSelected([NSColor.green, NSColor.blue]))
                gradientButton(colors: [NSColor.magenta, NSColor.purple], isSelected: isGradientSelected([NSColor.magenta, NSColor.purple]))
            }
        }
    }
    
    private func colorButton(color: NSColor, isSelected: Bool) -> some View {
        Button(action: {
            config.background = .color(color)
        }) {
            Circle()
                .fill(Color(nsColor: color))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func gradientButton(colors: [NSColor], isSelected: Bool) -> some View {
        Button(action: {
            config.background = .gradient(colors)
        }) {
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(colors: colors.map { Color(nsColor: $0) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 40, height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func isColorSelected(_ color: NSColor) -> Bool {
        if case .color(let bgColor) = config.background {
            return bgColor == color
        }
        return false
    }
    
    private func isGradientSelected(_ colors: [NSColor]) -> Bool {
        if case .gradient(let bgColors) = config.background {
            return bgColors == colors
        }
        return false
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        Group {
            if photos.isEmpty {
                VStack {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("添加照片以预览效果")
                        .foregroundColor(.secondary)
                }
            } else {
                GeometryReader { geometry in
                    let previewSize = calculatePreviewSize(containerSize: geometry.size)
                    if let image = generatePreview(size: previewSize) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(12)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: generateCollage) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    Text(isGenerating ? "生成中..." : "生成拼图")
                }
                .frame(maxWidth: .infinity)
                .padding(12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(photos.isEmpty || isGenerating)
            
            if generatedImage != nil {
                Button(action: { saveImage(generatedImage!) }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("保存")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Actions
    
    private func selectPhotos() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image]
        panel.message = "最多选择 \(selectedLayout.maxPhotos) 张图片"
        
        if panel.runModal() == .OK {
            let newPhotos = panel.urls.compactMap { url -> PhotoItem? in
                guard let image = NSImage(contentsOf: url) else { return nil }
                return PhotoItem(image: image)
            }
            
            photos = Array(newPhotos.prefix(selectedLayout.maxPhotos))
        }
    }
    
    private func applyInitialLayout() {
        if let initialLayout = initialLayout {
            selectedLayout = initialLayout
            config = CollageConfiguration(layout: initialLayout)
            photos = []
            navigationState.quickStartLayout = nil
        }
    }
    
    private func calculatePreviewSize(containerSize: CGSize) -> CGSize {
        if config.layout.isLongImage {
            guard !photos.isEmpty else { return CGSize(width: 400, height: 600) }
            
            let spacing = config.spacing
            var totalHeight: CGFloat = 0
            
            for photo in photos {
                let imageSize = photo.image.size
                guard imageSize.width > 0 else { continue }
                let scale = 300 / imageSize.width
                totalHeight += imageSize.height * scale + spacing
            }
            
            return CGSize(width: 300, height: max(400, totalHeight))
        }
        
        // 计算平均照片宽高比
        let avgAspectRatio = calculateAverageAspectRatio()
        
        let cols = CGFloat(config.layout.cols)
        let rows = CGFloat(config.layout.rows)
        let spacing = config.spacing
        
        // 使用容器尺寸和照片宽高比计算单元格尺寸
        let spacingMultiplierX = spacing == 0 ? 0 : (cols - 1)
        let spacingMultiplierY = spacing == 0 ? 0 : (rows - 1)
        let totalSpacingX = spacing * spacingMultiplierX
        let totalSpacingY = spacing * spacingMultiplierY
        
        // 基于照片宽高比计算单元格尺寸
        let cellHeight: CGFloat = 100
        let cellWidth = cellHeight * avgAspectRatio
        
        let contentWidth = cols * cellWidth
        let contentHeight = rows * cellHeight
        
        let totalWidth = contentWidth + totalSpacingX
        let totalHeight = contentHeight + totalSpacingY
        
        // 根据容器尺寸调整
        let containerAspectRatio = containerSize.width / containerSize.height
        let contentAspectRatio = totalWidth / totalHeight
        
        if containerAspectRatio > contentAspectRatio {
            // 容器更宽，以高度为基准
            let height = min(containerSize.height, totalHeight)
            let width = height * contentAspectRatio
            return CGSize(width: width, height: height)
        } else {
            // 容器更高，以宽度为基准
            let width = min(containerSize.width, totalWidth)
            let height = width / contentAspectRatio
            return CGSize(width: width, height: height)
        }
    }
    
    private func calculateAverageAspectRatio() -> CGFloat {
        guard !photos.isEmpty else { return 1.0 }
        
        var totalAspectRatio: CGFloat = 0.0
        var validCount: Int = 0
        
        for photo in photos {
            let size = photo.image.size
            guard size.width > 0 && size.height > 0 else { continue }
            
            let aspectRatio = size.width / size.height
            totalAspectRatio += aspectRatio
            validCount += 1
        }
        
        guard validCount > 0 else { return 1.0 }
        return totalAspectRatio / CGFloat(validCount)
    }
    
    private func calculatePreviewAspectRatio() -> CGFloat {
        if config.layout.isLongImage {
            guard !photos.isEmpty else { return 9.0/16.0 }
            
            let spacing = config.spacing
            let previewWidth: CGFloat = 100.0
            let availableWidth = previewWidth - spacing * 2
            
            var totalHeight: CGFloat = 0
            
            for photo in photos {
                let imageSize = photo.image.size
                guard imageSize.width > 0, imageSize.height > 0 else { continue }
                
                let scale = availableWidth / imageSize.width
                let photoHeight = imageSize.height * scale
                totalHeight += photoHeight + spacing
            }
            
            totalHeight -= spacing
            
            let aspectRatio = previewWidth / totalHeight
            
            return max(0.1, min(1.0, aspectRatio))
        }
        
        let layout = config.layout
        let spacing = config.spacing
        
        let cols = CGFloat(layout.cols)
        let rows = CGFloat(layout.rows)
        
        let spacingMultiplierX: CGFloat = spacing == 0 ? 0 : (cols - 1)
        let spacingMultiplierY: CGFloat = spacing == 0 ? 0 : (rows - 1)
        
        let totalSpacingX = spacing * spacingMultiplierX
        let totalSpacingY = spacing * spacingMultiplierY
        
        // 使用图片的平均宽高比作为单元格的宽高比
        let avgPhotoAspectRatio = calculateAverageAspectRatio()
        let cellAspectRatio = avgPhotoAspectRatio
        let cellHeight: CGFloat = 100.0
        let cellWidth = cellHeight * cellAspectRatio
        
        let contentWidth = cols * cellWidth
        let contentHeight = rows * cellHeight
        
        let totalWidth = contentWidth + totalSpacingX
        let totalHeight = contentHeight + totalSpacingY
        
        guard totalHeight > 0 else { return 1.0 }
        
        return totalWidth / totalHeight
    }
    private func calculatePreviewSize() -> CGSize {
        if config.layout.isLongImage {
            guard !photos.isEmpty else { return CGSize(width: 400, height: 600) }
            
            let spacing = config.spacing
            var totalHeight: CGFloat = 0
            
            for photo in photos {
                let imageSize = photo.image.size
                guard imageSize.width > 0 else { continue }
                let scale = 300 / imageSize.width
                totalHeight += imageSize.height * scale + spacing
            }
            
            return CGSize(width: 300, height: max(400, totalHeight))
        }
        
        let cols = CGFloat(config.layout.cols)
        let rows = CGFloat(config.layout.rows)
        let cellSize: CGFloat = 100
        let spacing = config.spacing
        let width = cols * cellSize + (cols - 1) * spacing
        let height = rows * cellSize + (rows - 1) * spacing
        
        return CGSize(width: width, height: height)
    }
    
    private func generatePreview(size: CGSize) -> NSImage? {
        guard !photos.isEmpty else { return nil }
        
        return PhotoCollageEngine.shared.generateCollage(
            photos: photos,
            config: config,
            outputSize: size
        )
    }
    
    private func generateCollage() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let exportSize = self.calculateExportSize()
            
            let image = PhotoCollageEngine.shared.generateCollage(
                photos: self.photos,
                config: self.config,
                outputSize: exportSize
            )
            
            DispatchQueue.main.async {
                self.generatedImage = image
                self.isGenerating = false
            }
        }
    }
    
    private func calculateExportSize() -> CGSize {
        if config.layout.isLongImage {
            return PhotoCollageEngine.shared.calculateLongImageSize(
                photos: photos,
                config: config,
                maxWidth: 7680
            )
        } else {
            let aspectRatio = calculatePreviewAspectRatio()
            let width: CGFloat = 7680
            let height = width / aspectRatio
            return CGSize(width: width, height: height.rounded())
        }
        if config.layout.isLongImage {
            return PhotoCollageEngine.shared.calculateLongImageSize(
                photos: photos,
                config: config,
                maxWidth: 3840
            )
        } else {
            let width: CGFloat = 3840
            let height = width / 1.0
            return CGSize(width: width, height: height.rounded())
        }
    }
    
    private func saveImage(_ image: NSImage) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.nameFieldStringValue = "拼图.png"
        
        if panel.runModal() == .OK, let url = panel.url {
            if let tiffData = image.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData) {
                let imageData = url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg"
                    ? bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
                    : bitmap.representation(using: .png, properties: [:])
                
                try? imageData?.write(to: url)
            }
        }
    }
}

// MARK: - Supporting Views

struct LayoutButton: View {
    let layout: CollageLayout
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                layoutIcon
                    .frame(height: 40)
                
                Text(layout.displayName)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .foregroundColor(isSelected ? .accentColor : .primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var layoutIcon: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 2
            
            if layout == .longImage {
                VStack(spacing: spacing) {
                    Rectangle().fill(Color.gray.opacity(0.3))
                    Rectangle().fill(Color.gray.opacity(0.3))
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
            } else {
                let cols = CGFloat(layout.cols)
                let rows = CGFloat(layout.rows)
                let cellWidth = (geometry.size.width - spacing * (cols - 1)) / cols
                let cellHeight = (geometry.size.height - spacing * (rows - 1)) / rows
                
                VStack(spacing: spacing) {
                    ForEach(0..<layout.rows, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<layout.cols, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: cellWidth, height: cellHeight)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CreateView()
        .environmentObject(NavigationState.shared)
}
