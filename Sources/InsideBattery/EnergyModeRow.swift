import AppKit

/// Handle mouse activation in the view rather than selecting a command item,
/// so AppKit continues tracking the menu after the mode action is sent.
@MainActor
final class EnergyModeRow: NSView {
    private weak var item: NSMenuItem?
    private var hoverTrackingArea: NSTrackingArea?
    private var hovered = false

    init(item: NSMenuItem) {
        self.item = item
        super.init(frame: NSRect(x: 0, y: 0, width: 310, height: 32))
        autoresizingMask = [.width]
        setAccessibilityElement(true)
        setAccessibilityRole(.button)
        setAccessibilityLabel(item.title)
    }

    required init?(coder: NSCoder) { fatalError("Use init(item:)") }

    override func draw(_ dirtyRect: NSRect) {
        guard let item else { return }
        let highlighted = hovered && item.isEnabled
        if highlighted {
            NSColor.selectedContentBackgroundColor.setFill()
            NSBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 1), xRadius: 5, yRadius: 5).fill()
        }
        item.image?.draw(in: NSRect(x: 14, y: bounds.midY - 14, width: 28, height: 28),
                         from: .zero, operation: .sourceOver, fraction: item.isEnabled ? 1 : 0.4)
        let title = NSAttributedString(string: item.title, attributes: [
            .font: NSFont.menuFont(ofSize: 13),
            .foregroundColor: !item.isEnabled ? NSColor.disabledControlTextColor
                : highlighted ? NSColor.selectedMenuItemTextColor : NSColor.labelColor
        ])
        title.draw(at: NSPoint(x: 50, y: bounds.midY - title.size().height / 2))
    }

    override func mouseDown(with event: NSEvent) {}

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let hoverTrackingArea { removeTrackingArea(hoverTrackingArea) }
        let area = NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self)
        addTrackingArea(area)
        hoverTrackingArea = area
    }

    override func mouseEntered(with event: NSEvent) { hovered = true; needsDisplay = true }
    override func mouseExited(with event: NSEvent) { hovered = false; needsDisplay = true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        hovered = false
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard bounds.contains(convert(event.locationInWindow, from: nil)) else { return }
        activate()
    }

    override func accessibilityPerformPress() -> Bool { activate() }

    @discardableResult
    private func activate() -> Bool {
        guard let item, item.isEnabled, let action = item.action else { return false }
        return NSApp.sendAction(action, to: item.target, from: item)
    }

    func refresh() {
        setAccessibilityEnabled(item?.isEnabled ?? false)
        setAccessibilityValue(item?.accessibilityValue())
        needsDisplay = true
    }
}
