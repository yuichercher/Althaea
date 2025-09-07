// AlthaeaApp.swift

import SwiftUI
import AppKit

@main
struct AlthaeaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 256, height: 256)
                .background(Color.clear)
                .ignoresSafeArea()
        }
        .windowStyle(.hiddenTitleBar)        // 隐藏 Title Bar
        .defaultSize(width: 256, height: 256)
        .windowResizability(.contentSize)    // 禁止用户随意拉伸
        .windowLevel(.floating)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let win = NSApp.windows.first else { return }

        // 1. 完全透明
        win.isOpaque = false
        win.backgroundColor = .clear

        // 2. 去掉标题栏背景
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true
        // 3. 彻底无标题
        win.styleMask.remove(.titled)

        // 4. 始终置顶：将窗口置于普通窗口之上（不使用系统保留的更高层级），前面有 windowLevel 就可以不用这个
        // win.windowLevel(.floating)

        // 5. 跨所有 Spaces：无论用户切换到哪个桌面（Space），此窗口都可见
        win.collectionBehavior.insert(.canJoinAllSpaces)

        // 6. 全屏 App 辅助窗口：在本 App 的全屏空间中也能显示（作为辅助层）
        win.collectionBehavior.insert(.fullScreenAuxiliary)

        // 7. 在 Mission Control/Stage Manager 下尽量保持位置与可见性（就是滑窗口变成多个，这时候是否可见）
        win.collectionBehavior.insert(.stationary)

        // 8. 应用失去激活时也保持显示（不随失焦隐藏）
        win.hidesOnDeactivate = false

       // 9. 启动时将窗口提升到其层级的最前面，但不抢占激活状态
        win.orderFrontRegardless()

        win.hasShadow = false
    }
}
