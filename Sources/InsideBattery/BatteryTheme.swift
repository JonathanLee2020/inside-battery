import AppKit

enum BatteryTheme: String, CaseIterable, Sendable {
    case joey, meadow, yoshi, tidepool, ember

    static let preferenceKey = "batteryTheme"

    static func selected(in defaults: UserDefaults = .standard) -> BatteryTheme {
        defaults.string(forKey: preferenceKey).flatMap(Self.init(rawValue:)) ?? .joey
    }

    static var current: BatteryTheme { selected() }

    func save(in defaults: UserDefaults = .standard) {
        defaults.set(rawValue, forKey: Self.preferenceKey)
    }

    var title: String {
        switch self {
        case .joey: "💜 Joey 💜"
        case .meadow: "Meadow"
        case .yoshi: "Yoshi"
        case .tidepool: "Tidepool"
        case .ember: "Ember"
        }
    }

    var detail: String {
        switch self {
        case .joey: "Soft lavender battery fill."
        case .meadow: "Original grey battery fill, green while connected to power."
        case .yoshi: "Sunshine yellow charge fill with a lavender empty portion."
        case .tidepool: "Sea-glass blue battery fill."
        case .ember: "Warm apricot battery fill."
        }
    }

    private func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
        NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
    }

    func progress(for mode: PowerMode, externalPower: Bool = false) -> NSColor {
        switch self {
        case .joey: rgb(0.85, 0.74, 0.95)
        case .meadow: externalPower ? rgb(0.35, 0.95, 0.50) : rgb(0.90, 0.90, 0.90)
        case .yoshi: rgb(0.95, 0.83, 0.42)
        case .tidepool: rgb(0.65, 0.89, 0.91)
        case .ember: rgb(0.97, 0.78, 0.60)
        }
    }

    func number(for mode: PowerMode) -> NSColor { .black }

    func surface(for mode: PowerMode) -> NSColor {
        self == .yoshi ? rgb(0.81, 0.64, 0.91) : rgb(0.72, 0.72, 0.72)
    }

    static func outline(for mode: PowerMode) -> NSColor? {
        switch mode {
        case .automatic: nil
        case .low: NSColor(srgbRed: 0.78, green: 0.57, blue: 0.08, alpha: 1)
        case .high: NSColor(srgbRed: 0.48, green: 0.24, blue: 0.69, alpha: 1)
        }
    }

    func selection(for mode: PowerMode) -> NSColor {
        switch mode {
        case .automatic: .systemBlue
        case .low: .systemYellow
        case .high: rgb(0.86, 0.69, 0.98)
        }
    }

    func symbol(for mode: PowerMode) -> NSColor { mode == .automatic ? .white : .black }

    static func menuIcon() -> NSImage {
        let colors: [NSColor] = [.systemBlue, .systemOrange, .systemGreen,
                                NSColor(srgbRed: 0.58, green: 0.30, blue: 0.82, alpha: 1)]
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            for (index, color) in colors.enumerated() {
                color.setFill()
                NSBezierPath(roundedRect: NSRect(x: (index % 2) * 10, y: (1 - index / 2) * 10,
                                                width: 8, height: 8), xRadius: 2, yRadius: 2).fill()
            }
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = "Themes"
        return image
    }

    func swatchImage() -> NSImage {
        let swatches = [progress(for: .automatic), progress(for: .automatic, externalPower: true),
                        Self.outline(for: .low)!, Self.outline(for: .high)!, surface(for: .automatic), number(for: .automatic)]
        let image = NSImage(size: NSSize(width: 116, height: 18), flipped: false) { _ in
            for (index, color) in swatches.enumerated() {
                color.setFill()
                let path = NSBezierPath(roundedRect: NSRect(x: index * 20, y: 1, width: 16, height: 16), xRadius: 2, yRadius: 2)
                path.fill()
                NSColor.gray.withAlphaComponent(0.3).setStroke()
                path.lineWidth = 0.5
                path.stroke()
            }
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = detail
        return image
    }
}
