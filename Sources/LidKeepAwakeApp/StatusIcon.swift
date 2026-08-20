import AppKit

enum StatusIcon {
    private static let canvasHeight: CGFloat = 18
    private static let moonSize: CGFloat = 16
    private static let spacing: CGFloat = 3

    static func image(enabled: Bool, hasError: Bool) -> NSImage {
        if hasError {
            return symbolImage(named: "exclamationmark.triangle")
        }

        let label = enabled ? "on" : "off"
        let moonName = enabled ? "moon.fill" : "moon"
        let labelFont = NSFont.systemFont(ofSize: 10.5, weight: .semibold)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: NSColor.black
        ]
        let labelSize = (label as NSString).size(withAttributes: labelAttributes)
        let imageSize = NSSize(
            width: moonSize + spacing + labelSize.width,
            height: canvasHeight
        )

        let image = NSImage(size: imageSize)
        image.lockFocus()
        defer { image.unlockFocus() }

        let symbolConfiguration = NSImage.SymbolConfiguration(
            pointSize: moonSize,
            weight: .regular
        )
        let moon = NSImage(systemSymbolName: moonName, accessibilityDescription: nil)?
            .withSymbolConfiguration(symbolConfiguration)
        let moonRect = NSRect(
            x: 0,
            y: (canvasHeight - moonSize) / 2,
            width: moonSize,
            height: moonSize
        )
        moon?.draw(in: moonRect)

        let labelPoint = NSPoint(
            x: moonSize + spacing,
            y: (canvasHeight - labelSize.height) / 2
        )
        (label as NSString).draw(at: labelPoint, withAttributes: labelAttributes)

        image.isTemplate = true
        return image
    }

    private static func symbolImage(named name: String) -> NSImage {
        let configuration = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let image = NSImage(systemSymbolName: name, accessibilityDescription: "macbook-keepawake")?
            .withSymbolConfiguration(configuration)
            ?? NSImage(size: NSSize(width: 18, height: 18))
        image.isTemplate = true
        return image
    }
}
