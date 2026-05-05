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
struct SpriteKitView: UIViewRepresentable {
    var services: ServiceContainer

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.showsFPS       = false
        view.showsNodeCount = false
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        guard uiView.scene == nil, uiView.bounds.size != .zero else { return }
        let scene = MenuScene(services: services)
        scene.scaleMode = .resizeFill
        scene.size = uiView.bounds.size
        uiView.presentScene(scene)
    }
}
#elseif os(macOS)
struct SpriteKitView: NSViewRepresentable {
    var services: ServiceContainer

    func makeNSView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.showsFPS       = false
        view.showsNodeCount = false
        return view
    }

    func updateNSView(_ nsView: SKView, context: Context) {
        guard nsView.scene == nil, nsView.bounds.size != .zero else { return }
        let scene = MenuScene(services: services)
        scene.scaleMode = .resizeFill
        scene.size = nsView.bounds.size
        nsView.presentScene(scene)
    }
}
#endif
