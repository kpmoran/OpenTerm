// Regenerates the OpenTerm app icon.
// Usage: swift Tools/make_app_icon.swift OpenTerm/Assets.xcassets/AppIcon.appiconset

import AppKit

// Draws the OpenTerm app icon (a terminal window) on a 1024-unit canvas, following
// the macOS icon grid (824-unit body inset 100 from each edge).
func drawIcon(in ctx: CGContext) {
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let radius: CGFloat = 185
    let titleBarHeight: CGFloat = 168

    // Coordinates below are top-left based.
    ctx.translateBy(x: 0, y: 1024)
    ctx.scaleBy(x: 1, y: -1)

    let bodyPath = CGPath(roundedRect: body, cornerWidth: radius, cornerHeight: radius, transform: nil)

    // Drop shadow.
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 12), blur: 28, color: CGColor(gray: 0, alpha: 0.35))
    ctx.addPath(bodyPath)
    ctx.setFillColor(CGColor(gray: 0.1, alpha: 1))
    ctx.fillPath()
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(bodyPath)
    ctx.clip()

    // Terminal body.
    let space = CGColorSpaceCreateDeviceRGB()
    let bodyGradient = CGGradient(colorsSpace: space, colors: [
        CGColor(red: 0.16, green: 0.17, blue: 0.19, alpha: 1),
        CGColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1),
    ] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(bodyGradient, start: CGPoint(x: 0, y: body.minY), end: CGPoint(x: 0, y: body.maxY), options: [])

    // Title bar.
    let titleBar = CGRect(x: body.minX, y: body.minY, width: body.width, height: titleBarHeight)
    let titleGradient = CGGradient(colorsSpace: space, colors: [
        CGColor(red: 0.93, green: 0.93, blue: 0.94, alpha: 1),
        CGColor(red: 0.80, green: 0.80, blue: 0.82, alpha: 1),
    ] as CFArray, locations: [0, 1])!
    ctx.saveGState()
    ctx.clip(to: titleBar)
    ctx.drawLinearGradient(titleGradient, start: CGPoint(x: 0, y: titleBar.minY), end: CGPoint(x: 0, y: titleBar.maxY), options: [])
    ctx.restoreGState()
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35))
    ctx.fill(CGRect(x: body.minX, y: titleBar.maxY - 4, width: body.width, height: 4))

    // Window buttons.
    let buttonColors = [
        CGColor(red: 1.00, green: 0.37, blue: 0.34, alpha: 1),
        CGColor(red: 1.00, green: 0.74, blue: 0.18, alpha: 1),
        CGColor(red: 0.16, green: 0.79, blue: 0.25, alpha: 1),
    ]
    for (index, color) in buttonColors.enumerated() {
        let center = CGPoint(x: body.minX + 112 + CGFloat(index) * 84, y: titleBar.midY)
        ctx.setFillColor(color)
        ctx.fillEllipse(in: CGRect(x: center.x - 30, y: center.y - 30, width: 60, height: 60))
    }

    // Prompt: ">_".
    let promptColor = CGColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1)
    ctx.setStrokeColor(promptColor)
    ctx.setLineWidth(62)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.move(to: CGPoint(x: 250, y: 410))
    ctx.addLine(to: CGPoint(x: 400, y: 520))
    ctx.addLine(to: CGPoint(x: 250, y: 630))
    ctx.strokePath()
    ctx.setFillColor(promptColor)
    ctx.addPath(CGPath(roundedRect: CGRect(x: 450, y: 600, width: 210, height: 60), cornerWidth: 20, cornerHeight: 20, transform: nil))
    ctx.fillPath()

    ctx.restoreGState()

    // Hairline edge so the icon holds up on dark backgrounds.
    ctx.addPath(CGPath(roundedRect: body.insetBy(dx: 1.5, dy: 1.5), cornerWidth: radius - 1.5, cornerHeight: radius - 1.5, transform: nil))
    ctx.setStrokeColor(CGColor(gray: 1, alpha: 0.12))
    ctx.setLineWidth(3)
    ctx.strokePath()
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1])
for pixels in [16, 32, 64, 128, 256, 512, 1024] {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    let ctx = context.cgContext
    ctx.interpolationQuality = .high
    ctx.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
    drawIcon(in: ctx)
    context.flushGraphics()
    try! rep.representation(using: .png, properties: [:])!.write(to: outputDirectory.appendingPathComponent("icon_\(pixels).png"))
}
