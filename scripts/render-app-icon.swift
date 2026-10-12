import AppKit

// Original vector artwork, rendered at every macOS app-icon size.
// Run from the repository root, then package the iconset with iconutil.
let output = URL(fileURLWithPath: ".build/app-icon.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r / 255, green: g / 255, blue: b / 255, alpha: 1)
}

func render(pixels: Int) throws -> Data {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels,
        pixelsHigh: pixels, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
        isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    let scale = CGFloat(pixels) / 1024
    context.cgContext.scaleBy(x: scale, y: scale)

    let tile = NSBezierPath(roundedRect: NSRect(x: 64, y: 64, width: 896, height: 896),
        xRadius: 194, yRadius: 194)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
    shadow.shadowOffset = NSSize(width: 0, height: -12)
    shadow.shadowBlurRadius = 24
    shadow.set()
    color(46, 41, 55).setFill()
    tile.fill()
    NSGraphicsContext.restoreGraphicsState()
    NSGradient(starting: color(65, 35, 98), ending: color(105, 62, 149))!
        .draw(in: tile, angle: 90)
    NSColor.white.withAlphaComponent(0.09).setStroke()
    tile.lineWidth = 4
    tile.stroke()

    let ink = color(245, 241, 250)
    let battery = NSBezierPath(roundedRect: NSRect(x: 186, y: 366, width: 592, height: 292),
        xRadius: 70, yRadius: 70)
    ink.setStroke()
    battery.lineWidth = 32
    battery.stroke()

    let fill = NSBezierPath(roundedRect: NSRect(x: 230, y: 410, width: 504, height: 204),
        xRadius: 28, yRadius: 28)
    NSGradient(starting: color(71, 207, 110), ending: color(143, 237, 163))!
        .draw(in: fill, angle: 90)
    let terminal = NSBezierPath(roundedRect: NSRect(x: 808, y: 455, width: 40, height: 114),
        xRadius: 19, yRadius: 19)
    ink.setFill()
    terminal.fill()

    NSGraphicsContext.restoreGraphicsState()
    return bitmap.representation(using: .png, properties: [:])!
}

for points in [16, 32, 128, 256, 512] {
    for multiplier in [1, 2] {
        let suffix = multiplier == 2 ? "@2x" : ""
        try render(pixels: points * multiplier)
            .write(to: output.appendingPathComponent("icon_\(points)x\(points)\(suffix).png"))
    }
}
try render(pixels: 1024).write(to: URL(fileURLWithPath: "Resources/AppIcon.png"))
print("PASS: rendered ten app-icon sizes and Resources/AppIcon.png")
