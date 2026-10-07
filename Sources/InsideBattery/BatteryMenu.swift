import AppKit

@MainActor
enum BatteryMenu {
    static func header(for state: BatteryState) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 310, height: 76))
        func label(_ text: String, x: CGFloat, y: CGFloat, width: CGFloat, bold: Bool = false) {
            let field = NSTextField(labelWithString: text)
            field.frame = NSRect(x: x, y: y, width: width, height: 20)
            field.font = .systemFont(ofSize: 13, weight: bold ? .semibold : .regular)
            field.textColor = .labelColor
            view.addSubview(field)
        }
        label("Battery", x: 14, y: 50, width: 210, bold: true)
        label(state.isPresent ? "\(state.percentage)%" : "—", x: 254, y: 50, width: 44, bold: true)
        label("Power Source: " + (state.isExternalPowerConnected ? "Power Adapter" : "Battery"),
              x: 14, y: 26, width: 282)
        let status = !state.isPresent ? "Battery unavailable"
            : state.isCharging ? "Charging"
            : state.isExternalPowerConnected ? (state.percentage == 100 ? "Fully Charged" : "Not Charging")
            : "On Battery Power"
        label(status, x: 14, y: 8, width: 282)
        view.setAccessibilityElement(true)
        view.setAccessibilityLabel(state.accessibilityLabel)
        return view
    }

    static func modeImage(_ mode: PowerMode, selected: Bool, appearance: NSAppearance? = nil) -> NSImage {
        let ink: NSColor = appearance?.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .white : .black
        let image = NSImage(size: NSSize(width: 28, height: 28), flipped: false) { bounds in
            (selected ? NSColor.systemBlue : ink.withAlphaComponent(0.25)).setFill()
            NSBezierPath(ovalIn: bounds.insetBy(dx: 1, dy: 1)).fill()
            let color = selected ? NSColor.white : ink
            color.setStroke()
            color.setFill()
            let body = NSRect(x: 5, y: 9, width: 17, height: 10)
            let outline = NSBezierPath(roundedRect: body, xRadius: 2, yRadius: 2)
            outline.lineWidth = 1.25
            outline.stroke()
            NSRect(x: 23, y: 12, width: 1, height: 4).fill()
            if mode == .high {
                for x: CGFloat in [7, 11, 15] {
                    let arrow = NSBezierPath()
                    arrow.move(to: NSPoint(x: x, y: 11))
                    arrow.line(to: NSPoint(x: x + 3, y: 14))
                    arrow.line(to: NSPoint(x: x, y: 17))
                    arrow.close()
                    arrow.fill()
                }
            } else {
                let fill = NSRect(x: 7, y: 11, width: mode == .low ? 3 : 13, height: 6)
                NSBezierPath(roundedRect: fill, xRadius: 1, yRadius: 1).fill()
            }
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = mode.title
        return image
    }
}
