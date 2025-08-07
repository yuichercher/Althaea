//
//  Untitled.swift
//  Althaea
//
//  Created by Yui Cher on 2025/8/7.
//

import SwiftUICore

class SpriteImageView: ClickThroughImageView {
    private var frameCount: Int = 4
    private var timer: Timer?
    private var currentFrame = 0 {
        didSet { updateContentsRect() }
    }
    /// 每帧间隔（秒）
    private var frameInterval: TimeInterval = 0.1

    func configureAnimation(frameCount: Int, fps: Int) {
        self.frameCount = frameCount
        self.frameInterval = 1.0 / Double(fps)
        startAnimation()
    }

    private func startAnimation() {
        stopAnimation()
        timer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentFrame = (self.currentFrame + 1) % self.frameCount
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }

    private func updateContentsRect() {
        guard let layer = self.layer else { return }
        let sliceWidth = 1.0 / CGFloat(frameCount)
        let x = sliceWidth * CGFloat(currentFrame)
        layer.contentsRect = CGRect(x: x, y: 0, width: sliceWidth, height: 1)
    }

    deinit {
        stopAnimation()
    }
}
