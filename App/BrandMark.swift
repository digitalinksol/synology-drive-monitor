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

/// Menu-bar mark from the supplied artwork: dark-blue arrow, light-blue D.
struct MenuBarMark: View {
    var side: CGFloat = 18

    var body: some View {
        Image(nsImage: MenuBarArtwork.image)
            .resizable()
            .renderingMode(.original)
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
        for url in menuMarkURLs() {
            if let image = NSImage(contentsOf: url), image.size.width > 8 {
                image.isTemplate = false
                return image
            }
        }
        return NSImage(size: NSSize(width: 18, height: 18))
    }()

    private static func menuMarkURLs() -> [URL] {
        var urls: [URL] = []
        if let url = Bundle.main.url(forResource: "MenuMark", withExtension: "png") {
            urls.append(url)
        }
        if let resource = Bundle.main.resourceURL {
            urls.append(resource.appendingPathComponent("MenuMark.png"))
            urls.append(resource.appendingPathComponent("DriveMonitorUI_DriveMonitorUI.bundle/MenuMark.png"))
        }
        let executable = Bundle.main.bundleURL
        urls.append(executable.appendingPathComponent("Contents/Resources/MenuMark.png"))
        urls.append(executable.deletingLastPathComponent().appendingPathComponent("MenuMark.png"))
        return urls
    }
}
