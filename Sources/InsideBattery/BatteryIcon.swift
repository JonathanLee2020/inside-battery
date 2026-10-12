import AppKit

enum BatteryIcon {
    static let size = NSSize(width: 35, height: 18)
    static let automaticColor = BatteryTheme.joey.progress(for: .automatic)

    // The theme controls the interior; only the outline indicates energy mode.
    static func colors(for state: BatteryState, appearance: NSAppearance?, theme: BatteryTheme = .joey) -> (surface: NSColor, number: NSColor, progress: NSColor) {
        let mode: PowerMode = state.isLowPowerMode && state.isPresent ? .low
            : state.isHighPowerMode && state.isPresent ? .high : .automatic
        return (theme.surface(for: mode), theme.number(for: mode),
                theme.progress(for: mode, externalPower: state.isExternalPowerConnected && state.isPresent))
    }

    static func image(for state: BatteryState, appearance: NSAppearance?, theme: BatteryTheme = .joey) -> NSImage {
        let imageSize = NSSize(width: state.isExternalPowerConnected && state.isPresent ? size.width : 30,
                               height: size.height)
        let image = NSImage(size: imageSize, flipped: false) { bounds in
            draw(state: state, in: bounds, appearance: appearance, theme: theme)
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = state.accessibilityLabel
        return image
    }

    private static func draw(state: BatteryState, in bounds: NSRect, appearance: NSAppearance?, theme: BatteryTheme) {
        let palette = colors(for: state, appearance: appearance, theme: theme)
        let body = NSRect(x: 1, y: 2, width: 25, height: 14)
        let bodyPath = NSBezierPath(roundedRect: body, xRadius: 3.5, yRadius: 3.5)
        palette.surface.setFill()
        bodyPath.fill()

        if state.isPresent && state.percentage > 0 {
            NSGraphicsContext.saveGraphicsState()
            bodyPath.addClip()
            palette.progress.setFill()
            NSRect(x: body.minX, y: body.minY, width: body.width * CGFloat(state.percentage) / 100, height: body.height).fill()
            NSGraphicsContext.restoreGraphicsState()
        }

        let mode: PowerMode = state.isLowPowerMode && state.isPresent ? .low
            : state.isHighPowerMode && state.isPresent ? .high : .automatic
        if let outline = BatteryTheme.outline(for: mode) {
            outline.setStroke()
            bodyPath.lineWidth = 1.75
            bodyPath.stroke()
        }

        palette.surface.setFill()
        NSBezierPath(roundedRect: NSRect(x: 27, y: 6.5, width: 1.5, height: 5), xRadius: 0.75, yRadius: 0.75).fill()
        if state.isExternalPowerConnected && state.isPresent {
            // Keep a fixed-size accessory slot beside the battery terminal.
            let dark = appearance?.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            (dark ? NSColor.white : .black).setFill()
            if state.isCharging {
                let bolt = NSBezierPath()
                bolt.move(to: NSPoint(x: 33.5, y: 14))
                bolt.line(to: NSPoint(x: 29, y: 8))
                bolt.line(to: NSPoint(x: 31.5, y: 8))
                bolt.line(to: NSPoint(x: 30, y: 4))
                bolt.line(to: NSPoint(x: 34.5, y: 10))
                bolt.line(to: NSPoint(x: 32, y: 10))
                bolt.close()
                bolt.fill()
            } else {
                // Two prongs, a rounded plug body, and a short cable remain recognizable
                // at menu-bar size without enlarging the status item.
                NSRect(x: 30, y: 11, width: 1.25, height: 3).fill()
                NSRect(x: 32.5, y: 11, width: 1.25, height: 3).fill()
                NSBezierPath(roundedRect: NSRect(x: 29, y: 6, width: 5.5, height: 5.5), xRadius: 1.5, yRadius: 1.5).fill()
                NSBezierPath(roundedRect: NSRect(x: 31.125, y: 3.5, width: 1.25, height: 3.5), xRadius: 0.5, yRadius: 0.5).fill()
            }
        }

        guard state.isPresent else {
            drawText("—", in: body, color: palette.number)
            return
        }

        drawText("\(state.percentage)", in: body, color: palette.number)
    }

    private static func drawText(_ text: String, in rect: NSRect, color: NSColor) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 10.5, weight: .bold),
            .foregroundColor: color
        ]
        let label = NSAttributedString(string: text, attributes: attributes)
        let measured = label.size()
        label.draw(at: NSPoint(
            x: rect.midX - measured.width / 2,
            y: rect.midY - measured.height / 2
        ))
    }
}
