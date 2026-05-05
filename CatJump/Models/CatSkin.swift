import SpriteKit

enum PatternType: String, CaseIterable {
    case solid, tabby, spotted, tuxedo, calico, bicolor, colorpoint, marbled
}

enum BodyScale: String, CaseIterable {
    case normal, chonky, slim
}

struct CatSkin {
    let id: String
    let name: String
    let bodyColor: SKColor
    let bellyColor: SKColor
    let eyeColor: SKColor
    let patternColor: SKColor
    let patternType: PatternType
    let bodyScale: BodyScale
    let price: Int
    let isDefault: Bool
}

private func color(_ rgb: UInt32) -> SKColor {
    SKColor(
        red:   CGFloat((rgb >> 16) & 0xFF) / 255,
        green: CGFloat((rgb >> 8)  & 0xFF) / 255,
        blue:  CGFloat( rgb        & 0xFF) / 255,
        alpha: 1
    )
}

enum CatSkins {
    static let all: [CatSkin] = [
        CatSkin(id: "classic_orange",    name: "Classic Orange",
                bodyColor: color(0xE8844D), bellyColor: color(0xFFC9A0),
                eyeColor:  color(0x4CAF50), patternColor: color(0xB85C2A),
                patternType: .tabby,      bodyScale: .normal, price: 0,   isDefault: true),

        CatSkin(id: "snow_white",        name: "Snow White",
                bodyColor: color(0xF5F5F5), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x64B5F6), patternColor: color(0xE0E0E0),
                patternType: .solid,      bodyScale: .normal, price: 100, isDefault: false),

        CatSkin(id: "midnight_black",    name: "Midnight Black",
                bodyColor: color(0x1A1A2E), bellyColor: color(0x2D2D44),
                eyeColor:  color(0xFFEB3B), patternColor: color(0x0D0D1A),
                patternType: .solid,      bodyScale: .normal, price: 150, isDefault: false),

        CatSkin(id: "silver_tabby",      name: "Silver Tabby",
                bodyColor: color(0xB0BEC5), bellyColor: color(0xECEFF1),
                eyeColor:  color(0x29B6F6), patternColor: color(0x78909C),
                patternType: .tabby,      bodyScale: .normal, price: 200, isDefault: false),

        CatSkin(id: "brown_tabby",       name: "Brown Tabby",
                bodyColor: color(0x8D6E63), bellyColor: color(0xD7CCC8),
                eyeColor:  color(0x8BC34A), patternColor: color(0x5D4037),
                patternType: .tabby,      bodyScale: .normal, price: 150, isDefault: false),

        CatSkin(id: "calico",            name: "Calico",
                bodyColor: color(0xFFF8E1), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x66BB6A), patternColor: color(0xFF8A65),
                patternType: .calico,     bodyScale: .normal, price: 250, isDefault: false),

        CatSkin(id: "tuxedo",            name: "Tuxedo",
                bodyColor: color(0x212121), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x26C6DA), patternColor: color(0x424242),
                patternType: .tuxedo,     bodyScale: .normal, price: 200, isDefault: false),

        CatSkin(id: "blue_gray",         name: "Blue Gray",
                bodyColor: color(0x78909C), bellyColor: color(0xB0BEC5),
                eyeColor:  color(0xEF5350), patternColor: color(0x546E7A),
                patternType: .solid,      bodyScale: .normal, price: 175, isDefault: false),

        CatSkin(id: "cream",             name: "Cream",
                bodyColor: color(0xFFF9C4), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x42A5F5), patternColor: color(0xF9E79F),
                patternType: .solid,      bodyScale: .normal, price: 125, isDefault: false),

        CatSkin(id: "ginger",            name: "Ginger",
                bodyColor: color(0xFF8F00), bellyColor: color(0xFFCC80),
                eyeColor:  color(0x7CB342), patternColor: color(0xE65100),
                patternType: .tabby,      bodyScale: .normal, price: 175, isDefault: false),

        CatSkin(id: "tortoiseshell",     name: "Tortoiseshell",
                bodyColor: color(0x6D4C41), bellyColor: color(0xBCAAA4),
                eyeColor:  color(0xFFB300), patternColor: color(0xBF360C),
                patternType: .calico,     bodyScale: .normal, price: 225, isDefault: false),

        CatSkin(id: "siamese",           name: "Siamese",
                bodyColor: color(0xFFF8E1), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x1565C0), patternColor: color(0x4E342E),
                patternType: .colorpoint, bodyScale: .slim,   price: 300, isDefault: false),

        CatSkin(id: "bengal",            name: "Bengal",
                bodyColor: color(0xCD853F), bellyColor: color(0xFFDEAD),
                eyeColor:  color(0x43A047), patternColor: color(0x5D4037),
                patternType: .spotted,    bodyScale: .normal, price: 350, isDefault: false),

        CatSkin(id: "golden",            name: "Golden",
                bodyColor: color(0xFFD54F), bellyColor: color(0xFFF9C4),
                eyeColor:  color(0x00897B), patternColor: color(0xFF8F00),
                patternType: .solid,      bodyScale: .normal, price: 400, isDefault: false),

        CatSkin(id: "lavender",          name: "Lavender",
                bodyColor: color(0xCE93D8), bellyColor: color(0xF3E5F5),
                eyeColor:  color(0xAB47BC), patternColor: color(0xBA68C8),
                patternType: .solid,      bodyScale: .normal, price: 300, isDefault: false),

        CatSkin(id: "pink_cotton",       name: "Pink Cotton",
                bodyColor: color(0xF48FB1), bellyColor: color(0xFCE4EC),
                eyeColor:  color(0xE91E63), patternColor: color(0xF06292),
                patternType: .solid,      bodyScale: .chonky, price: 275, isDefault: false),

        CatSkin(id: "sphynx",            name: "Sphynx",
                bodyColor: color(0xD7A98B), bellyColor: color(0xEDC9AF),
                eyeColor:  color(0x7E57C2), patternColor: color(0xC4895B),
                patternType: .solid,      bodyScale: .slim,   price: 325, isDefault: false),

        CatSkin(id: "ragdoll",           name: "Ragdoll",
                bodyColor: color(0xFAFAFA), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x1E88E5), patternColor: color(0xBDBDBD),
                patternType: .colorpoint, bodyScale: .chonky, price: 350, isDefault: false),

        CatSkin(id: "russian_blue",      name: "Russian Blue",
                bodyColor: color(0x6699CC), bellyColor: color(0x90B8E0),
                eyeColor:  color(0x43A047), patternColor: color(0x4477AA),
                patternType: .solid,      bodyScale: .normal, price: 275, isDefault: false),

        CatSkin(id: "british_shorthair", name: "British Shorthair",
                bodyColor: color(0x9E9E9E), bellyColor: color(0xE0E0E0),
                eyeColor:  color(0xFF8F00), patternColor: color(0x757575),
                patternType: .solid,      bodyScale: .chonky, price: 250, isDefault: false),

        CatSkin(id: "abyssinian",        name: "Abyssinian",
                bodyColor: color(0xCD7F32), bellyColor: color(0xE8B87A),
                eyeColor:  color(0x8BC34A), patternColor: color(0x8B5E3C),
                patternType: .tabby,      bodyScale: .slim,   price: 300, isDefault: false),

        CatSkin(id: "marble",            name: "Marble",
                bodyColor: color(0xE0E0E0), bellyColor: color(0xF5F5F5),
                eyeColor:  color(0x5C6BC0), patternColor: color(0x9E9E9E),
                patternType: .marbled,    bodyScale: .normal, price: 375, isDefault: false),

        CatSkin(id: "forest_green",      name: "Forest Green",
                bodyColor: color(0x66BB6A), bellyColor: color(0xA5D6A7),
                eyeColor:  color(0xFF7043), patternColor: color(0x388E3C),
                patternType: .spotted,    bodyScale: .normal, price: 325, isDefault: false),

        CatSkin(id: "ocean_blue",        name: "Ocean Blue",
                bodyColor: color(0x29B6F6), bellyColor: color(0x81D4FA),
                eyeColor:  color(0x1565C0), patternColor: color(0x0277BD),
                patternType: .solid,      bodyScale: .normal, price: 350, isDefault: false),

        CatSkin(id: "sunset_red",        name: "Sunset Red",
                bodyColor: color(0xEF5350), bellyColor: color(0xFFCDD2),
                eyeColor:  color(0xFFB300), patternColor: color(0xB71C1C),
                patternType: .tabby,      bodyScale: .normal, price: 325, isDefault: false),

        CatSkin(id: "arctic",            name: "Arctic",
                bodyColor: color(0xE0F7FA), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x00BCD4), patternColor: color(0xB2EBF2),
                patternType: .bicolor,    bodyScale: .normal, price: 400, isDefault: false),

        CatSkin(id: "chocolate",         name: "Chocolate",
                bodyColor: color(0x795548), bellyColor: color(0xBCAAA4),
                eyeColor:  color(0xFFB300), patternColor: color(0x4E342E),
                patternType: .solid,      bodyScale: .chonky, price: 275, isDefault: false),

        CatSkin(id: "cosmic",            name: "Cosmic",
                bodyColor: color(0x7E57C2), bellyColor: color(0xD1C4E9),
                eyeColor:  color(0xE91E63), patternColor: color(0x4527A0),
                patternType: .spotted,    bodyScale: .normal, price: 500, isDefault: false),
    ]

    static let ORANGE = getById("classic_orange")

    static func getById(_ id: String) -> CatSkin {
        all.first { $0.id == id } ?? all[0]
    }
}
