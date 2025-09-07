import AppKit
import SwiftUI

/// 连续帧 + 透明像素点穿
final class AnimatedClickThroughImageView: NSImageView {
    private var frames: [CGImage] = []
    private var timer: Timer?
    private(set) var currentIndex = 0
    
    /// 动画帧率（改这个会自动重启定时器）
    var fps: Int = 8 { didSet { restartTimer() } }
    
    /// 透明阈值（0~255，<= 阈值视为透明，推荐 10~20）
    var alphaThreshold: UInt8 = 10
    
    // MARK: - Init
    // ① 让 SwiftUI 不按图片原始尺寸来布局
    override var intrinsicContentSize: NSSize {
        NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }
    
    override var mouseDownCanMoveWindow: Bool { true }
    
    override func mouseDown(with event: NSEvent) {
        self.window?.performDrag(with: event)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.clear(self.bounds)                // 清成透明
        }
        super.draw(dirtyRect)                     // 再交给 NSImageView 画当前帧
    }
    
    /// spriteSheet 要求是横向平铺（1 行 N 列）
    init(spriteSheet: NSImage, frameCount: Int, fps: Int) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.imageScaling = .scaleProportionallyUpOrDown
        self.animates = false
        self.isEditable = false
        self.wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        self.canDrawSubviewsIntoLayer = true
        self.fps = fps
        
        self.frames = Self.sliceHorizontally(spriteSheet: spriteSheet, frameCount: frameCount)
        if let cg = frames.first {
            self.image = NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height))
        }
        restartTimer()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    deinit { timer?.invalidate() }
    
    // MARK: - Timer / Frames
    
    private func restartTimer() {
        timer?.invalidate()
        guard fps > 0, frames.count > 1 else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(fps), repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentIndex = (self.currentIndex + 1) % self.frames.count
            let cg = self.frames[self.currentIndex]
            self.image = NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height))
            self.needsDisplay = true
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    /// 将横向 sprite sheet 切成若干帧
    static func sliceHorizontally(spriteSheet: NSImage, frameCount: Int) -> [CGImage] {
        guard let sheet = spriteSheet.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return [] }
        let w = sheet.width
        let h = sheet.height
        let frameW = w / max(frameCount, 1)
        var result: [CGImage] = []
        for i in 0..<frameCount {
            let rect = CGRect(x: i * frameW, y: 0, width: frameW, height: h)
            if let cg = sheet.cropping(to: rect) { result.append(cg) }
        }
        return result
    }
    
    // MARK: - 点穿（透明像素返回 nil）
    
    override var isOpaque: Bool { false }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        guard !frames.isEmpty else { return super.hitTest(point) }
        let cg = frames[currentIndex]
        
        // 以“等比适配（Aspect Fit）”计算当前帧在 view 中的绘制区域
        let frameW = CGFloat(cg.width)
        let frameH = CGFloat(cg.height)
        let scale = min(bounds.width / frameW, bounds.height / frameH)
        let drawnW = frameW * scale
        let drawnH = frameH * scale
        let originX = (bounds.width - drawnW) / 2.0
        let originY = (bounds.height - drawnH) / 2.0
        let drawnRect = CGRect(x: originX, y: originY, width: drawnW, height: drawnH)
        
        // 点在绘制区域外：直接穿透
        guard drawnRect.contains(point) else { return nil }
        
        // View 坐标 -> 图像像素坐标（注意 Y 翻转）
        let xInImage = (point.x - originX) * (frameW / drawnW)
        let yInImage = (point.y - originY) * (frameH / drawnH)
        let px = Int(xInImage.rounded(.down))
        let py = Int((frameH - yInImage).rounded(.down))
        
        guard px >= 0, px < cg.width, py >= 0, py < cg.height else { return nil }
        guard let provider = cg.dataProvider, let data = provider.data else {
            return super.hitTest(point)
        }
        let ptr = CFDataGetBytePtr(data)
        let bpp = cg.bitsPerPixel / 8
        let bpr = cg.bytesPerRow
        guard bpp >= 4, let base = ptr else { return super.hitTest(point) }
        
        let offset = py * bpr + px * bpp
        
        // 兼容不同像素格式，计算 alpha 所在下标
        let alphaIndex: Int
        switch cg.alphaInfo {
        case .premultipliedLast, .last, .noneSkipLast: alphaIndex = 3
        case .premultipliedFirst, .first, .noneSkipFirst: alphaIndex = 0
        default: alphaIndex = 3
        }
        let alpha = base[offset + alphaIndex]
        
        // 透明：返回 nil -> 事件穿透到底层应用；不透明：交给当前 view（可拖动）
        return (alpha <= alphaThreshold) ? nil : self
    }
    // MARK: - Debug
    private func debugWindowState(_ tag: String) {
        if let win = self.window {
            print("[Pet][\(tag)] win=\(Unmanaged.passUnretained(win).toOpaque()) level=\(win.level.rawValue) floating=\(win.level == .floating) key=\(win.isKeyWindow) main=\(win.isMainWindow) visible=\(win.isVisible) hidesOnDeactivate=\(win.hidesOnDeactivate) behaviors=\(win.collectionBehavior)")
        } else {
            print("[Pet][\(tag)] win=nil")
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        debugWindowState("viewDidMoveToWindow")
    }
    // MARK: - Context Menu（右键菜单，命中本视图时才出现；透明像素仍然穿透）
    override func menu(for event: NSEvent) -> NSMenu? {
        debugWindowState("menu(for:) begin")
        // 系统在“命中当前视图并触发上下文菜单手势”（右键或按住 Control 点击）时调用。
        // 若点在透明像素，本视图的 hitTest 会返回 nil，事件会传给下层应用，因此不会出现本菜单。
        let menu = NSMenu()

        let isFloatingOrAbove: Bool = {
            guard let lvl = self.window?.level else { return false }
            return lvl.rawValue >= NSWindow.Level.floating.rawValue
        }()
        let toggleTitle = isFloatingOrAbove ? "取消置顶" : "置顶"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleAlwaysOnTop(_:)), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApp(_:)), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func toggleAlwaysOnTop(_ sender: Any?) {
        debugWindowState("toggle before")
        guard let win = self.window else { return }
        // 切换窗口层级：普通层 <-> 浮动层（置顶）
        win.level = (win.level == .floating) ? .normal : .floating
        // 将窗口在当前层级置于最前，避免被同层挡住（不抢焦点）
        win.orderFrontRegardless()
        debugWindowState("toggle after")
    }

    @objc private func quitApp(_ sender: Any?) {
        NSApp.terminate(nil)
    }
}
