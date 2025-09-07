//
//  ContentView.swift
//  Althaea
//
//  Created by Yui Cher on 2025/8/4.
//

import SwiftUI
import AppKit
struct ContentView: View {
    var body: some View {
        // 假设 sprite sheet 名为 "walk2"，横向 4 帧，8fps
        if let image = NSImage(named: "walk") {
            SpriteView(nsImage: image, frameCount: 4, fps: 2, alphaThreshold: 10)
                .frame(width: 256, height: 256)
                .ignoresSafeArea()
        } else {
            Image("no-image")
                .resizable()
                .scaledToFill()
                .frame(width: 256, height: 256)
                .clipped()
        }
    }
}
