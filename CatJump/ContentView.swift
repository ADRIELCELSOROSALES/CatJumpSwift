import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var services = ServiceContainer()

    var body: some View {
        SpriteKitView(services: services)
            .ignoresSafeArea()
    }
}

// MARK: - Platform bridge

#if os(iOS) || os(visionOS)

// Custom SKView subclass so scene presentation happens in layoutSubviews,
// which is guaranteed to run after the view has its final non-zero bounds.
fileprivate final class SKHostView: SKView {
    var pendingServices: ServiceContainer?

    override func layoutSubviews() {
        super.layoutSubviews()
        guard scene == nil,
              bounds.size.width > 0, bounds.size.height > 0,
              let services = pendingServices else { return }
        pendingServices = nil
        let scene = MenuScene(services: services)
        scene.scaleMode = .resizeFill
        scene.size = bounds.size
        presentScene(scene)
    }
}

fileprivate struct SpriteKitView: UIViewRepresentable {
    var services: ServiceContainer

    func makeUIView(context: Context) -> SKHostView {
        let view = SKHostView()
        view.isUserInteractionEnabled = true
        view.ignoresSiblingOrder = true
        view.showsFPS       = false
        view.showsNodeCount = false
        view.pendingServices = services
        return view
    }

    func updateUIView(_ uiView: SKHostView, context: Context) {
        if uiView.scene == nil {
            uiView.pendingServices = services
            uiView.setNeedsLayout()
        }
    }
}

#elseif os(macOS)

fileprivate final class SKHostView: SKView {
    var pendingServices: ServiceContainer?

    override func layout() {
        super.layout()
        guard scene == nil,
              bounds.size.width > 0, bounds.size.height > 0,
              let services = pendingServices else { return }
        pendingServices = nil
        let scene = MenuScene(services: services)
        scene.scaleMode = .resizeFill
        scene.size = bounds.size
        presentScene(scene)
    }
}

fileprivate struct SpriteKitView: NSViewRepresentable {
    var services: ServiceContainer

    func makeNSView(context: Context) -> SKHostView {
        let view = SKHostView()
        view.ignoresSiblingOrder = true
        view.showsFPS       = false
        view.showsNodeCount = false
        view.pendingServices = services
        return view
    }

    func updateNSView(_ nsView: SKHostView, context: Context) {
        if nsView.scene == nil {
            nsView.pendingServices = services
            nsView.needsLayout = true
        }
    }
}

#endif
