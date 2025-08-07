//
//  SpiriteView.swift
//  Althaea
//
//  Created by Yui Cher on 2025/8/7.
//

import SwiftUI

struct SpriteView: NSViewRepresentable {
    let nsImage: NSImage
    let frameCount: Int
    let fps: Int

    func makeNSView(context: Context) -> SpriteImageView {
        let v = SpriteImageView()
        v.image = nsImage
        v.wantsLayer = true
        v.layer?.masksToBounds = true
        v.imageScaling = .scaleProportionallyUpOrDown
        // 配置动画
        v.configureAnimation(frameCount: frameCount, fps: fps)
        return v
    }

    func updateNSView(_ nsView: SpriteImageView, context: Context) {
        // 如果需要动态切换 spriteSheet 或 fps，可在这里重新调用
        // nsView.image = nsImage
        // nsView.configureAnimation(frameCount: frameCount, fps: fps)
    }
}
