import AppKit

enum BatteryTheme: String, CaseIterable, Sendable {
    case joey
    case turtwig = "meadow"
    case yoshi
    case piplup = "tidepool"
    case chimchar = "ember"
    case testJoey

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
        case .turtwig: "turtwig"
        case .yoshi: "Yoshi"
        case .piplup: "Piplup"
        case .chimchar: "Chimchar"
        case .testJoey: "Test Joey"
        }
    }

    var detail: String {
        switch self {
        case .joey: "Medium purple battery fill, slightly darker in High Power."
        case .turtwig: "Green battery fill in every energy mode."
        case .yoshi: "Automatic green on both power sources, Low Power yellow, High Power light lavender, with green charging symbols."
        case .piplup: "Cool blue battery fill."
        case .chimchar: "Soft red battery fill."
        case .testJoey: "Joey purple with a darker grey Automatic border."
        }
    }

    private func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
        NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
    }

    func progress(for mode: PowerMode, externalPower: Bool = false) -> NSColor {
        if (self == .joey || self == .testJoey) && mode == .high { return rgb(0.78, 0.60, 0.84) }
        if self == .yoshi {
            if mode == .low { return selection(for: mode) }
            if mode == .high { return rgb(0.82, 0.65, 0.94) }
        }
        return switch self {
        case .joey, .testJoey: rgb(0.80, 0.62, 0.86)
        case .turtwig: rgb(0.35, 0.95, 0.50)
        case .yoshi: rgb(0.55, 0.87, 0.65)
        case .piplup: rgb(0.57, 0.82, 0.90)
        case .chimchar: rgb(0.93, 0.52, 0.52)
        }
    }

    func number(for mode: PowerMode) -> NSColor {
        .black
    }

    func surface(for mode: PowerMode) -> NSColor {
        self == .yoshi && mode == .high ? rgb(0.62, 0.62, 0.66) : rgb(0.72, 0.72, 0.72)
    }

    static func outline(for mode: PowerMode) -> NSColor? {
        switch mode {
        case .automatic: NSColor.black.withAlphaComponent(0.35)
        case .low: NSColor(srgbRed: 0.78, green: 0.57, blue: 0.08, alpha: 1)
        case .high: NSColor(srgbRed: 0.48, green: 0.24, blue: 0.69, alpha: 1)
        }
    }

    func border(for mode: PowerMode, externalPower: Bool) -> (color: NSColor, width: CGFloat)? {
        if self == .joey && mode == .automatic { return (progress(for: mode, externalPower: externalPower), 1.75) }
        if self == .testJoey && mode == .automatic, let color = Self.outline(for: mode) { return (color, 1.75) }
        if let color = Self.outline(for: mode) { return (color, 2.0) }
        return nil
    }

    func accessoryColor(dark: Bool) -> NSColor {
        if self == .yoshi {
            return dark ? rgb(0.35, 0.95, 0.50) : rgb(0.07, 0.52, 0.25)
        }
        return dark ? .white : .black
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
