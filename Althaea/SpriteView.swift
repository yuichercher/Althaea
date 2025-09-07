import SwiftUI
import AppKit

struct SpriteView: NSViewRepresentable {
    let nsImage: NSImage          // 整张 sprite sheet
    let frameCount: Int           // 帧数（横向）
    let fps: Int                  // 帧率
    var alphaThreshold: UInt8 = 10
    
    func makeNSView(context: Context) -> AnimatedClickThroughImageView {
        let v = AnimatedClickThroughImageView(spriteSheet: nsImage, frameCount: frameCount, fps: fps)
        v.alphaThreshold = alphaThreshold
        return v
    }
    
    func updateNSView(_ v: AnimatedClickThroughImageView, context: Context) {
        v.fps = fps
        v.alphaThreshold = alphaThreshold
    }
}
