//
//  AlthaeaApp.swift
//  Althaea
//
//  Created by Yui Cher on 2025/8/4.
//

import SwiftUI

@main
struct AlthaeaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 256, height: 256)
        }
        .windowStyle(.hiddenTitleBar)        // <- 关键：把 Title Bar 藏掉
        .defaultSize(width: 256, height: 256)
        .windowResizability(.contentSize)    // 禁止用户随意拉伸
    }
}

// 这里做所有 NSWindow 级别的配置
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let win = NSApp.windows.first else { return }

        // 1. 完全透明
        win.isOpaque = false
        win.backgroundColor = .clear

        // 2. 去掉标题栏背景（隐藏掉 Title Bar）
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true

        // 3. 真正去掉整个 Title Bar 及三颗交通灯
        win.styleMask.remove(.titled)
        win.styleMask.insert(.borderless)

        // 4. 取消阴影、开启背景拖动
        win.hasShadow = false
        win.isMovableByWindowBackground = true // 拖拽可移动

        // （可选）如果你只想隐藏交通灯，但保留标题栏，
        // 可以注释掉上面 remove/insert borderless，启用下面三行：
//        win.standardWindowButton(.closeButton)?.isHidden = true
//        win.standardWindowButton(.miniaturizeButton)?.isHidden = true
//        win.standardWindowButton(.zoomButton)?.isHidden = true
    }
}
