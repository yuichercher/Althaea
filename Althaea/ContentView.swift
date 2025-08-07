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
        ClickThroughImage(nsImage: NSImage(named: "test")!)
            // .frame(width: 256, height:256)
            .background(Color.clear)
            .ignoresSafeArea()
//        SpriteView(
//                    nsImage: NSImage(named: "walk2")!,  // 你的 sprite sheet 名
//                    frameCount: 4,                     // 例如一共 4 帧
//                    fps: 8                             // 每秒 8 帧
//                )
//                .frame(width: 256, height: 256)
//                .background(Color.clear)
//                .ignoresSafeArea()
    }
}

#Preview("Light", traits: .sizeThatFitsLayout) {
    ContentView()
        .frame(width: 256, height: 256)
        .padding()
}
