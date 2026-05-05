import WidgetKit
import SwiftUI

@main
struct CatJumpLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            CatJumpLiveActivityWidget()
        }
    }
}
