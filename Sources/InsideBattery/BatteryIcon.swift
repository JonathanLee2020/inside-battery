import AppKit

enum BatteryIcon {
    static let size = NSSize(width: 36, height: 18)

    // Black numerals stay readable over both the grey remainder and the charge fill.
    static func colors(for state: BatteryState, appearance: NSAppearance?) -> (surface: NSColor, number: NSColor, progress: NSColor) {
        let surface = state.isHighPowerMode && state.isPresent
            ? NSColor(srgbRed: 0.74, green: 0.46, blue: 0.91, alpha: 1)
            : NSColor(srgbRed: 0.72, green: 0.72, blue: 0.72, alpha: 1)
        // Use the native system yellow, matching macOS's semantic Low Power color.
        let progress = state.isLowPowerMode && state.isPresent ? NSColor.systemYellow
            : state.isExternalPowerConnected && state.isPresent
            ? NSColor(srgbRed: 0.35, green: 0.95, blue: 0.5, alpha: 1)
            : state.isHighPowerMode && state.isPresent
            ? NSColor(srgbRed: 0.78, green: 0.49, blue: 0.96, alpha: 1)
            : NSColor(srgbRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        return (surface, .black, progress)
    }

    static func image(for state: BatteryState, appearance: NSAppearance?) -> NSImage {
        let image = NSImage(size: size, flipped: false) { bounds in
            draw(state: state, in: bounds, appearance: appearance)
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = state.accessibilityLabel
        return image
    }

    private static func draw(state: BatteryState, in bounds: NSRect, appearance: NSAppearance?) {
        let palette = colors(for: state, appearance: appearance)
        let body = NSRect(x: 1, y: 1, width: 25, height: 16)
        let bodyPath = NSBezierPath(roundedRect: body, xRadius: 4, yRadius: 4)
        palette.surface.setFill()
        bodyPath.fill()

        if state.isPresent && state.percentage > 0 {
            NSGraphicsContext.saveGraphicsState()
            bodyPath.addClip()
            palette.progress.setFill()
            NSRect(x: body.minX, y: body.minY, width: body.width * CGFloat(state.percentage) / 100, height: body.height).fill()
            NSGraphicsContext.restoreGraphicsState()
        }

        // Keep the silhouette visible against a light menu bar, including at 100%.
        (state.isHighPowerMode && state.isPresent
            ? NSColor(srgbRed: 0.65, green: 0.32, blue: 0.84, alpha: 1)
            : NSColor.black.withAlphaComponent(0.35)).setStroke()
        bodyPath.lineWidth = state.isHighPowerMode && state.isPresent ? 1.5 : 0.75
        bodyPath.stroke()

        palette.surface.setFill()
        NSBezierPath(roundedRect: NSRect(x: 27, y: 6, width: 2, height: 6), xRadius: 1, yRadius: 1).fill()
        if state.isHighPowerMode && state.isPresent {
            // A tiny fast-forward mark replaces the terminal, leaving the plug/
            // bolt slot free and keeping the original 36-point status-item width.
            palette.number.setStroke()
            let chevrons = NSBezierPath()
            for x: CGFloat in [25.5, 27.5] {
                chevrons.move(to: NSPoint(x: x, y: 7))
                chevrons.line(to: NSPoint(x: x + 1.5, y: 9))
                chevrons.line(to: NSPoint(x: x, y: 11))
            }
            chevrons.lineWidth = 1
            chevrons.stroke()
        }
        if state.isExternalPowerConnected && state.isPresent {
            // Keep a fixed-size accessory slot beside the battery terminal.
            let dark = appearance?.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            (dark ? palette.progress : palette.number).setFill()
            if state.isCharging {
                let bolt = NSBezierPath()
                bolt.move(to: NSPoint(x: 34.5, y: 14))
                bolt.line(to: NSPoint(x: 30, y: 8))
                bolt.line(to: NSPoint(x: 32.5, y: 8))
                bolt.line(to: NSPoint(x: 31, y: 4))
                bolt.line(to: NSPoint(x: 35.5, y: 10))
                bolt.line(to: NSPoint(x: 33, y: 10))
                bolt.close()
                bolt.fill()
            } else {
                // Two prongs, a rounded plug body, and a short cable remain recognizable
                // at menu-bar size without enlarging the status item.
                NSRect(x: 31, y: 11, width: 1.25, height: 3).fill()
                NSRect(x: 33.5, y: 11, width: 1.25, height: 3).fill()
                NSBezierPath(roundedRect: NSRect(x: 30, y: 6, width: 5.5, height: 5.5), xRadius: 1.5, yRadius: 1.5).fill()
                NSBezierPath(roundedRect: NSRect(x: 32.125, y: 3.5, width: 1.25, height: 3.5), xRadius: 0.5, yRadius: 0.5).fill()
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
