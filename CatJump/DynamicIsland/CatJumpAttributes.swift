// Shared between the app target and the CatJumpLiveActivity extension target.
// In Xcode: select this file → File Inspector → Target Membership → enable both targets.

import ActivityKit

struct CatJumpAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        var score:     Int
        var lives:     Int
        var level:     Int
        var isGameOver: Bool
    }

    var playerName: String
}
