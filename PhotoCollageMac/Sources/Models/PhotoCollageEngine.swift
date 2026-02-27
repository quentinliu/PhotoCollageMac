import AppKit
import CoreImage

/// Collage layout types
enum CollageLayout: String, CaseIterable, Identifiable {
    case grid2x2 = "2x2"
    case grid1x3 = "1x3"
    case grid3x1 = "3x1"
    case grid2x3 = "2x3"
    case grid3x2 = "3x2"
    case grid3x3 = "3x3"
    case grid4x4 = "4x4"
    case freeform = "freeform"
    case longImage = "long"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .grid2x2: return "2 × 2"
        case .grid1x3: return "1 × 3"
        case .grid3x1: return "3 × 1"
        case .grid2x3: return "2 × 3"
        case .grid3x2: return "3 × 2"
        case .grid3x3: return "3 × 3"
        case .grid4x4: return "4 × 4"
        case .freeform: return "Free"
        case .longImage: return "Long"
        }
    }
    
    var rows: Int {
        switch self {
        case .grid2x2: return 2
        case .grid1x3: return 1
        case .grid3x1: return 3
        case .grid2x3: return 2
        case .grid3x2: return 3
        case .grid3x3: return 3
        case .grid4x4: return 4
        case .freeform: return 1
        case .longImage: return 1
        }
    }
    
    var cols: Int {
        switch self {
        case .grid2x2: return 2
        case .grid1x3: return 3
        case .grid3x1: return 1
        case .grid2x3: return 3
        case .grid3x2: return 2
        case .grid3x3: return 3
        case .grid4x4: return 4
        case .freeform: return 1
        case .longImage: return 1
        }
    }
    
    var maxPhotos: Int {
        switch self {
        case .grid2x2: return 4
        case .grid1x3: return 3
        case .grid3x1: return 3
        case .grid2x3: return 6
        case .grid3x2: return 6
        case .grid3x3: return 9
        case .grid4x4: return 16
        case .freeform: return 20
        case .longImage: return 9
        }
    }
    
    var isLongImage: Bool {
        return self == .longImage
    }
}

/// Background type for collage
enum BackgroundType: Equatable {
    case color(NSColor)
    case gradient([NSColor])
    case image(NSImage)
    case pattern(String)
    
    static func == (lhs: BackgroundType, rhs: BackgroundType) -> Bool {
        switch (lhs, rhs) {
        case (.color(let l), .color(let r)):
            return l == r
        case (.gradient(let l), .gradient(let r)):
            return l == r
        case (.image, .image):
            return true
        case (.pattern(let l), .pattern(let r)):
            return l == r
        default:
            return false
        }
    }
}

/// Configuration for collage generation
struct CollageConfiguration: Equatable {
    var layout: CollageLayout = .grid3x3
    var spacing: CGFloat = 4
    var cornerRadius: CGFloat = 8
    var background: BackgroundType = .color(.white)
    var borderWidth: CGFloat = 0
    var borderColor: NSColor = .clear
    var aspectRatio: CGFloat = 1.0
}

/// Photo item for collage
struct PhotoItem: Identifiable, Equatable {
    let id = UUID()
    var image: NSImage
    var cropRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    var zoomScale: CGFloat = 1.0
    var rotation: CGFloat = 0
}

/// Layout calculation result
struct LayoutInfo {
    let frames: [CGRect]
}

/// Photo Collage Engine - Core engine for generating collages
class PhotoCollageEngine {
    static let shared = PhotoCollageEngine()
    
    private init() {}
    
    /// Generate a collage image from photos
    func generateCollage(
        photos: [PhotoItem],
        config: CollageConfiguration,
        outputSize: CGSize
    ) -> NSImage? {
        guard !photos.isEmpty else { return nil }
        
        if config.layout == .longImage {
            return generateLongImage(photos: photos, config: config, outputSize: outputSize)
        }
        
        let format = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(outputSize.width),
            pixelsHigh: Int(outputSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        
        guard let bitmap = format else { return nil }
        
        NSGraphicsContext.saveGraphicsState()
        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            NSGraphicsContext.restoreGraphicsState()
            return nil
        }
        
        NSGraphicsContext.current = context
        let cgContext = context.cgContext
        
        drawBackground(context: cgContext, size: outputSize, background: config.background)
        
        let uniformSpacing = max(0, config.spacing)
        
        let layoutInfo = calculateLayout(
            photoCount: photos.count,
            layout: config.layout,
            size: outputSize,
            spacing: uniformSpacing
        )
        
        for (index, photo) in photos.enumerated() {
            guard index < layoutInfo.frames.count else { break }
            let frame = layoutInfo.frames[index]
            drawPhoto(
                context: cgContext,
                photo: photo,
                frame: frame,
                cornerRadius: config.cornerRadius,
                borderWidth: config.borderWidth,
                borderColor: config.borderColor
            )
        }
        
        NSGraphicsContext.restoreGraphicsState()
        
        let image = NSImage(size: outputSize)
        image.addRepresentation(bitmap)
        return image
    }
    
    /// Generate a long/vertical image collage
    func generateLongImage(
        photos: [PhotoItem],
        config: CollageConfiguration,
        outputSize: CGSize
    ) -> NSImage? {
        guard !photos.isEmpty else { return nil }
        
        let maxWidth: CGFloat = outputSize.width
        let spacing = config.spacing
        
        let safeSpacing = max(0, spacing)
        let safeMaxWidth = max(1, maxWidth)
        
        let availableWidth = max(1, safeMaxWidth - safeSpacing * 2)
        
        var totalHeight: CGFloat = 0
        var photoSizes: [(CGSize, CGFloat)] = []
        var validPhotos: [PhotoItem] = []
        
        for photo in photos {
            let imageSize = photo.image.size
            guard imageSize.width > 0 else { continue }
            
            let scale = availableWidth / imageSize.width
            let scaledHeight = max(1, imageSize.height * scale)
            photoSizes.append((CGSize(width: availableWidth, height: scaledHeight), scale))
            validPhotos.append(photo)
            totalHeight += scaledHeight + safeSpacing
        }
        
        guard !photoSizes.isEmpty else { return nil }
        
        totalHeight -= safeSpacing
        let finalHeight = max(1, totalHeight)
        let finalSize = CGSize(width: safeMaxWidth, height: finalHeight)
        
        let format = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(finalSize.width),
            pixelsHigh: Int(finalSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        
        guard let bitmap = format else { return nil }
        
        NSGraphicsContext.saveGraphicsState()
        guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            NSGraphicsContext.restoreGraphicsState()
            return nil
        }
        
        NSGraphicsContext.current = context
        let cgContext = context.cgContext
        
        drawBackground(context: cgContext, size: finalSize, background: config.background)
        
        var currentY: CGFloat = 0
        
        for (index, photo) in validPhotos.enumerated() {
            guard index < photoSizes.count else { break }
            let (size, _) = photoSizes[index]
            
            let frameWidth = max(1, availableWidth)
            let frameHeight = max(1, size.height)
            let frame = CGRect(x: safeSpacing, y: currentY, width: frameWidth, height: frameHeight)
            
            drawPhotoInLongImage(
                context: cgContext,
                photo: photo,
                frame: frame,
                cornerRadius: config.cornerRadius
            )
            
            currentY += size.height + safeSpacing
        }
        
        NSGraphicsContext.restoreGraphicsState()
        
        let image = NSImage(size: finalSize)
        image.addRepresentation(bitmap)
        return image
    }
    
    /// Calculate the output size for long image
    func calculateLongImageSize(
        photos: [PhotoItem],
        config: CollageConfiguration,
        maxWidth: CGFloat
    ) -> CGSize {
        guard !photos.isEmpty else { return CGSize(width: maxWidth, height: maxWidth) }
        
        let spacing = config.spacing
        let safeSpacing = max(0, spacing)
        let safeMaxWidth = max(1, maxWidth)
        
        let availableWidth = max(1, safeMaxWidth - safeSpacing * 2)
        
        var totalHeight: CGFloat = 0
        
        for photo in photos {
            let imageSize = photo.image.size
            guard imageSize.width > 0 else { continue }
            
            let scale = availableWidth / imageSize.width
            let scaledHeight = max(1, imageSize.height * scale)
            totalHeight += scaledHeight + safeSpacing
        }
        
        totalHeight -= safeSpacing
        let finalHeight = max(1, totalHeight)
        return CGSize(width: safeMaxWidth, height: finalHeight)
    }
    
    // MARK: - Private Drawing Methods
    
    private func drawPhotoInLongImage(
        context: CGContext,
        photo: PhotoItem,
        frame: CGRect,
        cornerRadius: CGFloat
    ) {
        context.saveGState()
        
        let path = CGPath(roundedRect: frame, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        context.addPath(path)
        context.clip()
        
        let image = photo.image
        image.draw(in: frame)
        
        context.restoreGState()
    }
    
    private func drawBackground(context: CGContext, size: CGSize, background: BackgroundType) {
        let rect = CGRect(origin: .zero, size: size)
        
        switch background {
        case .color(let color):
            context.setFillColor(color.cgColor)
            context.fill(rect)
            
        case .gradient(let colors):
            guard colors.count >= 2 else {
                context.setFillColor(colors.first?.cgColor ?? NSColor.white.cgColor)
                context.fill(rect)
                return
            }
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let cgColors = colors.map { $0.cgColor } as CFArray
            
            guard let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: cgColors,
                locations: nil
            ) else { return }
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
        case .image(let image):
            image.draw(in: rect)
            
        case .pattern:
            context.setFillColor(NSColor.windowBackgroundColor.cgColor)
            context.fill(rect)
        }
    }
    
    private func calculateLayout(
        photoCount: Int,
        layout: CollageLayout,
        size: CGSize,
        spacing: CGFloat
    ) -> LayoutInfo {
        var frames: [CGRect] = []
        
        switch layout {
        case .grid2x2, .grid1x3, .grid3x1, .grid2x3, .grid3x2, .grid3x3, .grid4x4:
            frames = calculateGridLayout(
                rows: layout.rows,
                cols: layout.cols,
                count: photoCount,
                size: size,
                spacing: spacing
            )
            
        case .freeform:
            frames = calculateFreeformLayout(
                count: photoCount,
                size: size,
                spacing: spacing
            )
            
        case .longImage:
            frames = calculateLongImageLayout(
                count: photoCount,
                size: size,
                spacing: spacing
            )
        }
        
        return LayoutInfo(frames: frames)
    }
    
    private func calculateGridLayout(
        rows: Int,
        cols: Int,
        count: Int,
        size: CGSize,
        spacing: CGFloat
    ) -> [CGRect] {
        var frames: [CGRect] = []
        
        if spacing == 0 {
            let cellWidth = size.width / CGFloat(cols)
            let cellHeight = size.height / CGFloat(rows)
            
            for index in 0..<min(count, rows * cols) {
                let row = index / cols
                let col = index % cols
                
                let x = CGFloat(col) * cellWidth
                let y = CGFloat(row) * cellHeight
                
                let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                frames.append(frame)
            }
        } else {
            let availableWidth = size.width - spacing * CGFloat(cols - 1)
            let availableHeight = size.height - spacing * CGFloat(rows - 1)
            
            let cellWidth = availableWidth / CGFloat(cols)
            let cellHeight = availableHeight / CGFloat(rows)
            
            for index in 0..<min(count, rows * cols) {
                let row = index / cols
                let col = index % cols
                
                let x = CGFloat(col) * (cellWidth + spacing)
                let y = CGFloat(row) * (cellHeight + spacing)
                
                let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
                frames.append(frame)
            }
        }
        
        return frames
    }
    
    private func calculateFreeformLayout(
        count: Int,
        size: CGSize,
        spacing: CGFloat
    ) -> [CGRect] {
        var frames: [CGRect] = []
        
        let cols = min(count, 3)
        let rows = (count + cols - 1) / cols
        
        let availableWidth = size.width - spacing * CGFloat(cols + 1)
        let availableHeight = size.height - spacing * CGFloat(rows + 1)
        
        let cellWidth = availableWidth / CGFloat(cols)
        let cellHeight = availableHeight / CGFloat(rows)
        
        for index in 0..<count {
            let row = index / cols
            let col = index % cols
            
            let x = spacing + CGFloat(col) * (cellWidth + spacing)
            let y = spacing + CGFloat(row) * (cellHeight + spacing)
            
            let widthMultiplier: CGFloat = (index % 3 == 0) ? 1.2 : 1.0
            let heightMultiplier: CGFloat = (index % 4 == 0) ? 1.2 : 1.0
            
            let frame = CGRect(
                x: x,
                y: y,
                width: cellWidth * widthMultiplier,
                height: cellHeight * heightMultiplier
            )
            frames.append(frame)
        }
        
        return frames
    }
    
    private func calculateLongImageLayout(
        count: Int,
        size: CGSize,
        spacing: CGFloat
    ) -> [CGRect] {
        var frames: [CGRect] = []
        
        let cellWidth = size.width - spacing * 2
        let totalSpacing = spacing * CGFloat(count + 1)
        let totalHeight = size.height - totalSpacing
        let cellHeight = totalHeight / CGFloat(count)
        
        for index in 0..<count {
            let y = spacing + CGFloat(index) * (cellHeight + spacing)
            let frame = CGRect(x: spacing, y: y, width: cellWidth, height: cellHeight)
            frames.append(frame)
        }
        
        return frames
    }
    
    private func drawPhoto(
        context: CGContext,
        photo: PhotoItem,
        frame: CGRect,
        cornerRadius: CGFloat,
        borderWidth: CGFloat,
        borderColor: NSColor
    ) {
        context.saveGState()
        
        let path = CGPath(roundedRect: frame, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        context.addPath(path)
        context.clip()
        
        let image = photo.image
        let imageSize = image.size
        
        let photoScale = min(frame.width / imageSize.width, frame.height / imageSize.height)
        let scaledWidth = imageSize.width * photoScale
        let scaledHeight = imageSize.height * photoScale
        
        let xOffset = (frame.width - scaledWidth) / 2
        let yOffset = (frame.height - scaledHeight) / 2
        
        let drawRect = CGRect(
            x: frame.minX + xOffset,
            y: frame.minY + yOffset,
            width: scaledWidth,
            height: scaledHeight
        )
        
        let zoomedRect = drawRect.insetBy(
            dx: -drawRect.width * (photo.zoomScale - 1) / 2,
            dy: -drawRect.height * (photo.zoomScale - 1) / 2
        )
        
        image.draw(in: zoomedRect)
        
        context.restoreGState()
        
        if borderWidth > 0 {
            context.saveGState()
            context.setStrokeColor(borderColor.cgColor)
            context.setLineWidth(borderWidth)
            context.addPath(path)
            context.strokePath()
            context.restoreGState()
        }
    }
    
    /// Get recommended layouts based on photo count
    func getRecommendedLayouts(for photoCount: Int) -> [CollageLayout] {
        switch photoCount {
        case 1:
            return [.grid2x2]
        case 2...4:
            return [.grid2x2, .grid1x3, .grid3x1]
        case 5...6:
            return [.grid2x3, .grid3x2]
        case 7...9:
            return [.grid3x3, .grid2x3, .grid3x2]
        case 10...16:
            return [.grid4x4, .grid3x3]
        default:
            return [.grid3x3]
        }
    }
}
