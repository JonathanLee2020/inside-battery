import AppKit

// Compile alongside BatteryState.swift and BatteryIcon.swift; no GUI session required.
@main
struct IconPreview {
    static func main() throws {
        let output = CommandLine.arguments.dropFirst().first ?? "dist/battery-preview.png"
        let states: [(String, BatteryState)] = [
            ("0", BatteryState(percentage: 0, isCharging: false)),
            ("9", BatteryState(percentage: 9, isCharging: false)),
            ("20", BatteryState(percentage: 20, isCharging: false)),
            ("52", BatteryState(percentage: 52, isCharging: false)),
            ("73", BatteryState(percentage: 73, isCharging: false)),
            ("100", BatteryState(percentage: 100, isCharging: false)),
            ("Charging", BatteryState(percentage: 52, isCharging: true)),
            ("AC, not charging", BatteryState(percentage: 73, isCharging: false, isExternalPowerConnected: true)),
            ("Low Power", BatteryState(percentage: 52, isCharging: false, isLowPowerMode: true)),
            ("Low + charging", BatteryState(percentage: 52, isCharging: true, isLowPowerMode: true)),
            ("Low + plugged in", BatteryState(percentage: 73, isCharging: false, isExternalPowerConnected: true, isLowPowerMode: true)),
            ("High Power", BatteryState(percentage: 52, isCharging: false, isHighPowerMode: true)),
            ("High + charging", BatteryState(percentage: 52, isCharging: true, isHighPowerMode: true)),
            ("High + plugged in", BatteryState(percentage: 73, isCharging: false, isExternalPowerConnected: true, isHighPowerMode: true)),
            ("Unavailable", .unavailable)
        ]
        let width = states.count * 145 + 20
        let height = 360
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: width * 2, pixelsHigh: height * 2,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
            isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )!
        bitmap.size = NSSize(width: width, height: height)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        for (row, appearanceName) in [NSAppearance.Name.aqua, .darkAqua].enumerated() {
            let dark = row == 1
            let y = CGFloat(1 - row) * 180
            (dark ? NSColor(white: 0.12, alpha: 1) : NSColor(white: 0.95, alpha: 1)).setFill()
            NSRect(x: 0, y: y, width: CGFloat(width), height: 180).fill()
            let textColor: NSColor = dark ? .white : .black
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 12), .foregroundColor: textColor
            ]
            (dark ? "Dark menu bar · actual size above, 3× below" : "Light menu bar · actual size above, 3× below")
                .draw(at: NSPoint(x: 20, y: y + 151), withAttributes: attributes)
            for (column, entry) in states.enumerated() {
                let x = CGFloat(column) * 145 + 20
                entry.0.draw(at: NSPoint(x: x, y: y + 125), withAttributes: attributes)
                let image = BatteryIcon.image(for: entry.1, appearance: NSAppearance(named: appearanceName))
                image.draw(in: NSRect(origin: NSPoint(x: x, y: y + 97), size: BatteryIcon.size))
                image.draw(in: NSRect(x: x, y: y + 22, width: BatteryIcon.size.width * 3, height: BatteryIcon.size.height * 3))
            }
        }
        NSGraphicsContext.restoreGraphicsState()
        try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: output))
        print("Rendered \(states.count * 2) battery states: \(output)")
    }
}
