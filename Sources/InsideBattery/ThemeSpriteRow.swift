import AppKit

@MainActor
final class ThemeSpriteRow: NSView {
    private weak var item: NSMenuItem?
    private let spriteView = NSImageView()
    private var tracking: NSTrackingArea?
    private var hovered = false

    static func loadSprite(named name: String) throws -> NSImage {
        let url = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/\(name).gif")
        let data = try Data(contentsOf: url)
        guard let image = NSImage(data: data) else {
            throw NSError(domain: "InsideBattery.ThemeSprite", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "The \(name) sprite could not be decoded."])
        }
        return image
    }

    init(item: NSMenuItem, sprite: NSImage) {
        self.item = item
        // Small baseline: 18×24pt sprite in a 28pt row; recorded in handoff.md.
        super.init(frame: NSRect(x: 0, y: 0, width: 260, height: 30))
        autoresizingMask = [.width]
        spriteView.frame = NSRect(x: 150, y: 2, width: 20, height: 26)
        spriteView.imageScaling = .scaleProportionallyUpOrDown
        spriteView.image = sprite
        spriteView.animates = true
        addSubview(spriteView)
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(item.title)
        toolTip = "\(item.title) — \(item.toolTip ?? "")"
    }

    required init?(coder: NSCoder) { fatalError("Use init(item:sprite:)") }

    override func hitTest(_ point: NSPoint) -> NSView? {
        super.hitTest(point) == nil ? nil : self
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let item else { return }
        if hovered && item.isEnabled {
            NSColor.selectedContentBackgroundColor.setFill()
            NSBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 1), xRadius: 5, yRadius: 5).fill()
        }
        item.image?.draw(in: NSRect(x: 22, y: bounds.midY - 9, width: 116, height: 18))
        if item.state == .on {
            let color: NSColor = hovered ? .selectedMenuItemTextColor : .labelColor
            NSAttributedString(string: "✓", attributes: [.font: NSFont.menuFont(ofSize: 13), .foregroundColor: color])
                .draw(at: NSPoint(x: 7, y: bounds.midY - 8))
        }
        setAccessibilityValue(item.state == .on ? "Selected" : "Not selected")
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let area = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self)
        addTrackingArea(area)
        tracking = area
    }

    override func mouseEntered(with event: NSEvent) { hovered = true; needsDisplay = true }
    override func mouseExited(with event: NSEvent) { hovered = false; needsDisplay = true }
    override func mouseDown(with event: NSEvent) {}
    override func mouseUp(with event: NSEvent) {
        guard bounds.contains(convert(event.locationInWindow, from: nil)) else { return }
        activate()
    }
    override func accessibilityPerformPress() -> Bool { activate() }

    @discardableResult
    private func activate() -> Bool {
        guard let item, item.isEnabled, let action = item.action else { return false }
        item.menu?.cancelTracking()
        return NSApp.sendAction(action, to: item.target, from: item)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        hovered = false
        needsDisplay = true
    }
}
