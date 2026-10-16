import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

struct Command: Decodable { let op: String; let points: [[Double]] }
let scriptFolder = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path
let base = scriptFolder + "/Шаблон"
let commands = try JSONDecoder().decode([Command].self, from: Data(contentsOf: URL(fileURLWithPath: base + "/contour.json")))
let contour = CGMutablePath()
for command in commands {
    let p = command.points.map { CGPoint(x: $0[0], y: $0[1]) }
    switch command.op {
    case "m": contour.move(to: p[0])
    case "l": contour.addLine(to: p[0])
    case "c": contour.addCurve(to: p[2], control1: p[0], control2: p[1])
    default: fatalError("Invalid contour")
    }
}
contour.closeSubpath()
func image(_ path: String) -> CGImage {
    guard let s = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL,nil), let i = CGImageSourceCreateImageAtIndex(s,0,nil) else { fatalError(path) }
    return i
}
func context(_ width: Int, _ height: Int, alpha: Bool = false) -> CGContext {
    let c = CGContext(data:nil,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:(alpha ? CGImageAlphaInfo.premultipliedLast : CGImageAlphaInfo.noneSkipLast).rawValue)!
    c.translateBy(x:0,y:CGFloat(height)); c.scaleBy(x:1,y:-1)
    c.interpolationQuality = .high
    return c
}
func drawImage(_ c: CGContext,_ i: CGImage,_ rect: CGRect) {
    c.saveGState(); c.translateBy(x:rect.minX,y:rect.maxY);c.scaleBy(x:1,y:-1)
    c.draw(i,in:CGRect(x:0,y:0,width:rect.width,height:rect.height));c.restoreGState()
}
func save(_ i: CGImage,_ path: String) {
    let d = CGImageDestinationCreateWithURL(URL(fileURLWithPath:path) as CFURL,UTType.png.identifier as CFString,1,nil)!
    CGImageDestinationAddImage(d,i,nil); precondition(CGImageDestinationFinalize(d))
}
let root = "/Users/zotchik/Documents/2. Репозиторий/Sudoky/Sudoky/Дизайн/Иконка-приложения-v7-чернила"
let reference = image(root + "/app-icon-circle.png")
let woodStrip = reference.cropping(to: CGRect(x:430,y:4,width:150,height:18))!
// Stroke on Apple's exact boundary, clipped to it: 32 px visible inward.
let rim = contour.copy(strokingWithWidth:64,lineCap:.butt,lineJoin:.round,miterLimit:10)
var boundarySamples = 0
var start = CGPoint.zero
func sample(_ p: CGPoint,_ tangent: CGPoint) {
    let length = hypot(tangent.x,tangent.y)
    guard length > 0 else { return }
    var normal = CGPoint(x:-tangent.y/length,y:tangent.x/length)
    if !contour.contains(CGPoint(x:p.x+normal.x*4,y:p.y+normal.y*4)) { normal.x = -normal.x; normal.y = -normal.y }
    for offset: CGFloat in [2,16,30] {
        let probe = CGPoint(x:p.x+normal.x*offset,y:p.y+normal.y*offset)
        precondition(contour.contains(probe) && rim.contains(probe),"Rim discontinuity")
    }
    boundarySamples += 1
}
for command in commands {
    let pts=command.points.map { CGPoint(x:$0[0],y:$0[1]) }
    if command.op == "m" { start=pts[0]; continue }
    for step in 0...100 {
        let t=CGFloat(step)/100, u=1-t
        if command.op == "l" {
            sample(CGPoint(x:u*start.x+t*pts[0].x,y:u*start.y+t*pts[0].y),CGPoint(x:pts[0].x-start.x,y:pts[0].y-start.y))
        } else {
            let p=CGPoint(x:u*u*u*start.x+3*u*u*t*pts[0].x+3*u*t*t*pts[1].x+t*t*t*pts[2].x,y:u*u*u*start.y+3*u*u*t*pts[0].y+3*u*t*t*pts[1].y+t*t*t*pts[2].y)
            let d=CGPoint(x:3*u*u*(pts[0].x-start.x)+6*u*t*(pts[1].x-pts[0].x)+3*t*t*(pts[2].x-pts[1].x),y:3*u*u*(pts[0].y-start.y)+6*u*t*(pts[1].y-pts[0].y)+3*t*t*(pts[2].y-pts[1].y))
            sample(p,d)
        }
    }
    start=pts.last!
}
let first = CGPoint(x:commands[0].points[0][0],y:commands[0].points[0][1])
for step in 0...100 {
    let t=CGFloat(step)/100
    sample(CGPoint(x:(1-t)*start.x+t*first.x,y:(1-t)*start.y+t*first.y),CGPoint(x:first.x-start.x,y:first.y-start.y))
}
print("Continuous 32px inward rim verified at",boundarySamples,"boundary samples")
let outputDir = scriptFolder + "/Rebuild"
try FileManager.default.createDirectory(atPath:outputDir,withIntermediateDirectories:true)
for variant in ["circle","plain"] {
    let source = image(root + "/app-icon-" + variant + ".png")
    let c = context(1024,1024)
    drawImage(c,source,CGRect(x:0,y:0,width:1024,height:1024))
    c.saveGState()
    c.addPath(rim); c.clip()
    c.setFillColor(CGColor(red:0.065,green:0.045,blue:0.035,alpha:1))
    c.fill(CGRect(x:0,y:0,width:1024,height:1024))
    c.setAlpha(0.6)
    for y in stride(from:0,to:1024,by:18) { for x in stride(from:0,to:1024,by:150) {
        drawImage(c,woodStrip,CGRect(x:x,y:y,width:150,height:18))
    }}
    c.restoreGState()
    let full = c.makeImage()!
    save(full,outputDir + "/app-icon-" + variant + "-apple.png")
    let preview = context(1024,1024,alpha:true)
    preview.addPath(contour);preview.clip()
    drawImage(preview,full,CGRect(x:0,y:0,width:1024,height:1024))
    save(preview.makeImage()!,outputDir + "/preview-" + variant + "-apple.png")
    for size in [120,180] {
        let small=context(size,size,alpha:true)
        drawImage(small,preview.makeImage()!,CGRect(x:0,y:0,width:size,height:size))
        save(small.makeImage()!,outputDir + "/preview-" + variant + "-" + String(size) + "px.png")
    }
}
// Rasterized official contour only for masks / programmatic checks.
let mask = context(1024,1024,alpha:true)
mask.setFillColor(CGColor(gray:1,alpha:1));mask.addPath(contour);mask.fillPath()
save(mask.makeImage()!,outputDir + "/apple-mask.png")
print("Rendered both variants and previews using 44 original Apple path commands")
