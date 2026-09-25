import AppKit
import SwiftUI

/// Polished dock artwork shown in the open menu.
struct DockMark: View {
    var side: CGFloat = 44

    var body: some View {
        Image(nsImage: DockArtwork.image)
            .resizable()
            .interpolation(.high)
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: side * 0.223, style: .continuous))
            .accessibilityHidden(true)
    }
}

/// Menu-bar template of the mark: the D’s left stem is an upward arrow.
struct MenuBarMark: View {
    var side: CGFloat = 18

    var body: some View {
        Image(nsImage: MenuBarArtwork.image)
            .resizable()
            .renderingMode(.template)
            .interpolation(.high)
            .frame(width: side, height: side)
            .accessibilityHidden(true)
    }
}

@MainActor
enum DockArtwork {
    static let image: NSImage = {
        let urls = dockMarkURLs()
        for url in urls {
            if let image = NSImage(contentsOf: url), image.size.width > 8 {
                return image
            }
        }
        if let icon = NSApp.applicationIconImage, icon.size.width > 8 {
            return icon
        }
        return NSImage(size: NSSize(width: 128, height: 128))
    }()

    private static func dockMarkURLs() -> [URL] {
        var urls: [URL] = []
        if let url = Bundle.main.url(forResource: "DockMark", withExtension: "png") {
            urls.append(url)
        }
        if let resource = Bundle.main.resourceURL {
            urls.append(resource.appendingPathComponent("DockMark.png"))
            urls.append(resource.appendingPathComponent("DriveMonitorUI_DriveMonitorUI.bundle/DockMark.png"))
        }
        let executable = Bundle.main.bundleURL
        urls.append(executable.appendingPathComponent("Contents/Resources/DockMark.png"))
        urls.append(executable.deletingLastPathComponent().appendingPathComponent("DockMark.png"))
        return urls
    }
}

@MainActor
enum MenuBarArtwork {
    static let image: NSImage = {
        let side: CGFloat = 18
        let image = NSImage(size: NSSize(width: side, height: side), flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            let span = min(rect.width, rect.height)
            ctx.saveGState()
            ctx.translateBy(x: rect.minX, y: rect.maxY)
            ctx.scaleBy(x: 1, y: -1)
            // y increases downward after the flip above.
            let stemLeft = span * 0.37
            let stemWidth = span * 0.20
            let stemRight = stemLeft + stemWidth
            let outerRadius = span * 0.30
            let innerRadius = span * 0.15
            let tuck = span * 0.06
            let stemBottom = span * 0.94
            let centerY = stemBottom - outerRadius
            let headBase = span * 0.38
            let tip = span * 0.04
            let wing = span * 0.18
            let bowl = CGMutablePath()
            bowl.addEllipse(in: CGRect(x: stemRight - tuck - outerRadius, y: centerY - outerRadius, width: outerRadius * 2, height: outerRadius * 2))
            bowl.addEllipse(in: CGRect(x: stemRight - tuck - innerRadius, y: centerY - innerRadius, width: innerRadius * 2, height: innerRadius * 2))
            ctx.saveGState()
            ctx.clip(to: CGRect(x: stemRight - span * 0.02, y: 0, width: span, height: span))
            ctx.addPath(bowl)
            ctx.setFillColor(NSColor.black.cgColor)
            ctx.fillPath(using: .evenOdd)
            ctx.restoreGState()
            ctx.addPath(menuBarArrowPath(stemLeft: stemLeft, stemRight: stemRight, stemBottom: stemBottom, headBase: headBase, tip: tip, wing: wing, radius: span * 0.022))
            ctx.setFillColor(NSColor.black.cgColor)
            ctx.fillPath()
            ctx.restoreGState()
            return true
        }
        image.isTemplate = true
        return image
    }()
}

private func menuBarArrowPath(stemLeft: CGFloat, stemRight: CGFloat, stemBottom: CGFloat, headBase: CGFloat, tip: CGFloat, wing: CGFloat, radius: CGFloat) -> CGPath {
    let centerX = (stemLeft + stemRight) / 2
    let points = [
        CGPoint(x: centerX, y: tip),
        CGPoint(x: stemRight + wing, y: headBase),
        CGPoint(x: stemRight, y: headBase),
        CGPoint(x: stemRight, y: stemBottom),
        CGPoint(x: stemLeft, y: stemBottom),
        CGPoint(x: stemLeft, y: headBase),
        CGPoint(x: stemLeft - wing, y: headBase)
    ]
    let path = CGMutablePath()
    let count = points.count
    func inset(_ corner: CGPoint, toward: CGPoint) -> CGPoint {
        let dx = toward.x - corner.x
        let dy = toward.y - corner.y
        let length = max(hypot(dx, dy), 0.001)
        let distance = min(radius, length / 2)
        return CGPoint(x: corner.x + dx / length * distance, y: corner.y + dy / length * distance)
    }
    path.move(to: inset(points[0], toward: points[count - 1]))
    for index in 0..<count {
        path.addArc(tangent1End: points[index], tangent2End: points[(index + 1) % count], radius: radius)
    }
    path.closeSubpath()
    return path
}
