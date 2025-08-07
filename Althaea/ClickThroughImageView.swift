//
//  ClickThroughImageView.swift
//  Althaea
//
//  Created by Yui Cher on 2025/8/5.
//
import AppKit
import SwiftUI

class ClickThroughImageView: NSImageView {
    override var isOpaque: Bool { false }
    
    override var mouseDownCanMoveWindow: Bool { true }
    
    override func mouseDown(with event: NSEvent) {
        // let the window start dragging
        self.window?.performDrag(with: event)
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let img = image else { return super.hitTest(point) }
        let localPoint = convert(point, from: nil)
        let xRatio = img.size.width / bounds.width
        let yRatio = img.size.height / bounds.height
        let pixelX = Int(localPoint.x * xRatio)
        let pixelY = Int((bounds.height - localPoint.y) * yRatio)
        guard
          pixelX >= 0, pixelX < Int(img.size.width),
          pixelY >= 0, pixelY < Int(img.size.height),
          let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return super.hitTest(point) }
        let data = cg.dataProvider!.data
        let ptr  = CFDataGetBytePtr(data)!
        let bytesPerPixel = cg.bitsPerPixel / 8
        let offset = (pixelY * cg.bytesPerRow) + (pixelX * bytesPerPixel)
        let alpha = ptr[offset + 3]
        return alpha == 0 ? nil : super.hitTest(point)
    }
}

struct ClickThroughImage: NSViewRepresentable {
    let nsImage: NSImage
    func makeNSView(context: Context) -> ClickThroughImageView {
        let v = ClickThroughImageView()
        v.image = nsImage
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.clear.cgColor

        // 让视图愿意按父容器尺寸布局
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentHuggingPriority(.defaultLow, for: .vertical)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        v.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
        v.imageAlignment = .alignCenter
        return v
    }
    func updateNSView(_ nsView: ClickThroughImageView, context: Context) {
        nsView.image = nsImage
    }
}
