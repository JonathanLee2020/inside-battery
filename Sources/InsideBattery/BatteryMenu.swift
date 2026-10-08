import AppKit

@MainActor
enum BatteryMenu {
    static func header(for state: BatteryState, showTimeUntilFull: Bool = true) -> NSView {
        let detailRowHeight: CGFloat = 17
        let extraHeight: CGFloat = state.isExternalPowerConnected ? detailRowHeight : 0
        let estimate = showTimeUntilFull ? state.timeUntilFullLabel : nil
        let estimateHeight: CGFloat = estimate == nil ? 0 : detailRowHeight
        let headerOffset = extraHeight + estimateHeight
        let bottomPadding: CGFloat = 2
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 310, height: 48 + bottomPadding + headerOffset))
        func label(_ text: String, x: CGFloat, y: CGFloat, width: CGFloat, bold: Bool = false) {
            let field = NSTextField(labelWithString: text)
            field.frame = NSRect(x: x, y: y, width: width, height: bold ? 20 : detailRowHeight)
            field.font = .systemFont(ofSize: bold ? 13 : 12, weight: bold ? .semibold : .regular)
            field.textColor = bold ? .labelColor : .secondaryLabelColor
            view.addSubview(field)
        }
        label("Battery", x: 14, y: 22 + bottomPadding + headerOffset, width: 210, bold: true)
        label(state.isPresent ? "\(state.percentage)%" : "—", x: 254, y: 22 + bottomPadding + headerOffset, width: 44, bold: true)
        let status = !state.isPresent ? "Battery unavailable"
            : state.isCharging ? "Charging"
            : state.isExternalPowerConnected ? (state.percentage == 100 ? "Fully Charged" : "Not Charging")
            : "On Battery Power"
        let source = state.isExternalPowerConnected ? "Power Adapter" : "Battery"
        let sourceLine = "Power Source: " + source
            + (state.isExternalPowerConnected || !state.isPresent ? " · " + status : "")
        label(sourceLine, x: 14, y: bottomPadding + headerOffset, width: 282)
        var accessibility = state.accessibilityLabel
        if let estimate {
            label(estimate, x: 14, y: bottomPadding + extraHeight, width: 282)
            accessibility += ", " + estimate
        }
        if state.isExternalPowerConnected {
            let capacity = "Charger capacity: " + (state.chargerCapacityWatts.map { "\($0) W" } ?? "Unavailable")
            label(capacity, x: 14, y: bottomPadding, width: 282)
            accessibility += ", " + capacity
            view.toolTip = "The charger's reported wattage capability, not live input or battery charging power."
        }
        view.setAccessibilityElement(true)
        view.setAccessibilityLabel(accessibility)
        return view
    }

    static func selectionColor(for mode: PowerMode) -> NSColor {
        switch mode {
        case .automatic: .systemBlue
        case .low: .systemYellow
        case .high: BatteryIcon.highPowerColor
        }
    }

    static func modeImage(_ mode: PowerMode, selected: Bool, appearance: NSAppearance? = nil) -> NSImage {
        let ink: NSColor = appearance?.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .white : .black
        let selectionColor = selectionColor(for: mode)
        let image = NSImage(size: NSSize(width: 28, height: 28), flipped: false) { bounds in
            (selected ? selectionColor : ink.withAlphaComponent(0.25)).setFill()
            NSBezierPath(ovalIn: bounds.insetBy(dx: 1, dy: 1)).fill()
            let color = selected ? (mode == .automatic ? NSColor.white : .black) : ink
            let outlineColor = selected
                ? (mode == .automatic ? NSColor(srgbRed: 0.80, green: 0.88, blue: 0.94, alpha: 1)
                   : NSColor.black.withAlphaComponent(0.65))
                : NSColor(srgbRed: 0.60, green: 0.60, blue: 0.62, alpha: 1)
            outlineColor.setStroke()
            outlineColor.setFill()
            let body = NSRect(x: 5, y: 10, width: 17, height: 8)
            let outline = NSBezierPath(roundedRect: body, xRadius: 2, yRadius: 2)
            outline.lineWidth = 1
            outline.stroke()
            NSRect(x: 23, y: 12.5, width: 1, height: 3).fill()
            color.setFill()
            if mode == .high {
                let arrowWidth: CGFloat = 3
                let spacing: CGFloat = 1
                let groupWidth = 3 * arrowWidth + 2 * spacing
                let startX = body.midX - groupWidth / 2
                for index in 0..<3 {
                    let x = startX + CGFloat(index) * (arrowWidth + spacing)
                    let arrow = NSBezierPath()
                    arrow.move(to: NSPoint(x: x, y: 12))
                    arrow.line(to: NSPoint(x: x + 3, y: 14))
                    arrow.line(to: NSPoint(x: x, y: 16))
                    arrow.close()
                    arrow.fill()
                }
            } else {
                let fill = NSRect(x: 7, y: 12, width: mode == .low ? 3 : 13, height: 4)
                NSBezierPath(roundedRect: fill, xRadius: 1, yRadius: 1).fill()
            }
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = mode.title
        return image
    }
}
