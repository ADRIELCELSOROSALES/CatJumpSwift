import Foundation

final class ScoreStore {

    private enum Keys {
        static let highScore    = "catjump_high_score"
        static let selectedSkin = "catjump_selected_skin"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var highScore: Int {
        get { defaults.integer(forKey: Keys.highScore) }
        set { defaults.set(newValue, forKey: Keys.highScore) }
    }

    var selectedSkinId: String {
        get { defaults.string(forKey: Keys.selectedSkin) ?? "classic_orange" }
        set { defaults.set(newValue, forKey: Keys.selectedSkin) }
    }
}
