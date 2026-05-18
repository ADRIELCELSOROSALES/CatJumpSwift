import SpriteKit

enum PatternType: String, CaseIterable {
    case solid, tabby, spotted, tuxedo, calico, bicolor, colorpoint, marbled
}

enum BodyScale: String, CaseIterable {
    case normal, chonky, slim
}

enum AccessoryType: String, CaseIterable {
    case none
    case topHat, crownGold, crownGem, cap, beanie, witchHat, cowboyHat, vikingHelmet
    case monocle, glasses, sunglasses, piratePatch
    case halo, antenna, alienAntenna
    case bowtie, ribbon, headphones
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
    let accessory: AccessoryType
    let accessoryColor: SKColor

    init(id: String, name: String,
         bodyColor: SKColor, bellyColor: SKColor,
         eyeColor: SKColor, patternColor: SKColor,
         patternType: PatternType, bodyScale: BodyScale,
         price: Int, isDefault: Bool,
         accessory: AccessoryType = .none,
         accessoryColor: SKColor = .clear) {
        self.id           = id
        self.name         = name
        self.bodyColor    = bodyColor
        self.bellyColor   = bellyColor
        self.eyeColor     = eyeColor
        self.patternColor = patternColor
        self.patternType  = patternType
        self.bodyScale    = bodyScale
        self.price        = price
        self.isDefault    = isDefault
        self.accessory      = accessory
        self.accessoryColor = accessoryColor
    }
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

        // ── Fantásticos ──────────────────────────────────────────────────────
        CatSkin(id: "galaxy",            name: "Galaxy",
                bodyColor: color(0x1A0A3C), bellyColor: color(0x2E1760),
                eyeColor:  color(0x00E5FF), patternColor: color(0x7C4DFF),
                patternType: .spotted,    bodyScale: .slim,   price: 550, isDefault: false),

        CatSkin(id: "nebula",            name: "Nebula",
                bodyColor: color(0x2C1654), bellyColor: color(0x6A1E8A),
                eyeColor:  color(0xFF4081), patternColor: color(0xE040FB),
                patternType: .marbled,    bodyScale: .normal, price: 575, isDefault: false),

        CatSkin(id: "stardust",          name: "Stardust",
                bodyColor: color(0xB0BEC5), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0xFFD740), patternColor: color(0xFFD700),
                patternType: .bicolor,    bodyScale: .slim,   price: 525, isDefault: false),

        CatSkin(id: "deep_sea",          name: "Deep Sea",
                bodyColor: color(0x004D5A), bellyColor: color(0x006978),
                eyeColor:  color(0x18FFFF), patternColor: color(0x00BFA5),
                patternType: .spotted,    bodyScale: .normal, price: 475, isDefault: false),

        // ── Vibrantes ─────────────────────────────────────────────────────────
        CatSkin(id: "cyber_neon",        name: "Cyber Neon",
                bodyColor: color(0x0D0D0D), bellyColor: color(0x1A1A1A),
                eyeColor:  color(0x39FF14), patternColor: color(0xFF006E),
                patternType: .tabby,      bodyScale: .slim,   price: 600, isDefault: false),

        CatSkin(id: "toxic_lime",        name: "Toxic Lime",
                bodyColor: color(0xB2FF59), bellyColor: color(0xF4FF81),
                eyeColor:  color(0xE040FB), patternColor: color(0x64DD17),
                patternType: .spotted,    bodyScale: .normal, price: 450, isDefault: false),

        CatSkin(id: "vampire",           name: "Vampire",
                bodyColor: color(0x6A0000), bellyColor: color(0x3D0000),
                eyeColor:  color(0xFF1744), patternColor: color(0x1A0000),
                patternType: .marbled,    bodyScale: .slim,   price: 500, isDefault: false),

        CatSkin(id: "lava",              name: "Lava",
                bodyColor: color(0xBF360C), bellyColor: color(0xFF6E40),
                eyeColor:  color(0xFFD740), patternColor: color(0x212121),
                patternType: .marbled,    bodyScale: .normal, price: 475, isDefault: false),

        CatSkin(id: "strawberry",        name: "Strawberry",
                bodyColor: color(0xE53935), bellyColor: color(0xFF8A80),
                eyeColor:  color(0x1B5E20), patternColor: color(0xB71C1C),
                patternType: .spotted,    bodyScale: .chonky, price: 400, isDefault: false),

        // ── Pasteles ──────────────────────────────────────────────────────────
        CatSkin(id: "cotton_candy",      name: "Cotton Candy",
                bodyColor: color(0xF8BBD0), bellyColor: color(0xE1F5FE),
                eyeColor:  color(0xCE93D8), patternColor: color(0xF48FB1),
                patternType: .bicolor,    bodyScale: .chonky, price: 375, isDefault: false),

        CatSkin(id: "sakura",            name: "Sakura",
                bodyColor: color(0xF8C8D4), bellyColor: color(0xFFF0F3),
                eyeColor:  color(0xFF80AB), patternColor: color(0xF48FB1),
                patternType: .spotted,    bodyScale: .normal, price: 375, isDefault: false),

        CatSkin(id: "mint_chip",         name: "Mint Chip",
                bodyColor: color(0xA5D6A7), bellyColor: color(0xE8F5E9),
                eyeColor:  color(0x4E342E), patternColor: color(0x4E342E),
                patternType: .spotted,    bodyScale: .normal, price: 350, isDefault: false),

        CatSkin(id: "bubblegum",         name: "Bubblegum",
                bodyColor: color(0xFF4DB8), bellyColor: color(0xFF99DD),
                eyeColor:  color(0x00BCD4), patternColor: color(0xCC0077),
                patternType: .solid,      bodyScale: .chonky, price: 425, isDefault: false),

        CatSkin(id: "coral_reef",        name: "Coral Reef",
                bodyColor: color(0xFF7043), bellyColor: color(0xFFCCBC),
                eyeColor:  color(0x0097A7), patternColor: color(0xBF360C),
                patternType: .spotted,    bodyScale: .normal, price: 375, isDefault: false),

        // ── Naturales ─────────────────────────────────────────────────────────
        CatSkin(id: "cinnamon_roll",     name: "Cinnamon Roll",
                bodyColor: color(0xA1613E), bellyColor: color(0xFFE0B2),
                eyeColor:  color(0x795548), patternColor: color(0x6D4C41),
                patternType: .marbled,    bodyScale: .chonky, price: 325, isDefault: false),

        CatSkin(id: "caramel_swirl",     name: "Caramel Swirl",
                bodyColor: color(0xCC8844), bellyColor: color(0xFFDDA0),
                eyeColor:  color(0x6D4C41), patternColor: color(0x8B5A2B),
                patternType: .marbled,    bodyScale: .normal, price: 350, isDefault: false),

        CatSkin(id: "matcha",            name: "Matcha",
                bodyColor: color(0x8BA888), bellyColor: color(0xC8D5B9),
                eyeColor:  color(0xD32F2F), patternColor: color(0x4E6B4E),
                patternType: .tabby,      bodyScale: .slim,   price: 375, isDefault: false),

        CatSkin(id: "desert_sand",       name: "Desert Sand",
                bodyColor: color(0xC9A96E), bellyColor: color(0xF0DCBA),
                eyeColor:  color(0xF57F17), patternColor: color(0x9E7B46),
                patternType: .tabby,      bodyScale: .normal, price: 300, isDefault: false),

        // ── Elementales ───────────────────────────────────────────────────────
        CatSkin(id: "storm_cloud",       name: "Storm Cloud",
                bodyColor: color(0x546E7A), bellyColor: color(0x90A4AE),
                eyeColor:  color(0xE3F2FD), patternColor: color(0x263238),
                patternType: .marbled,    bodyScale: .normal, price: 425, isDefault: false),

        CatSkin(id: "ice_queen",         name: "Ice Queen",
                bodyColor: color(0xCFECF9), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x00B0FF), patternColor: color(0x81D4FA),
                patternType: .colorpoint, bodyScale: .slim,   price: 450, isDefault: false),

        CatSkin(id: "ancient_gold",      name: "Ancient Gold",
                bodyColor: color(0xB8860B), bellyColor: color(0xFFD700),
                eyeColor:  color(0x1A237E), patternColor: color(0x7B5800),
                patternType: .marbled,    bodyScale: .chonky, price: 550, isDefault: false),

        CatSkin(id: "ghost",             name: "Ghost",
                bodyColor: color(0xF3F3F3), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0xB39DDB), patternColor: color(0xDDDDDD),
                patternType: .solid,      bodyScale: .slim,   price: 500, isDefault: false),

        CatSkin(id: "sunflower",         name: "Sunflower",
                bodyColor: color(0xFFCC00), bellyColor: color(0xFFF9C4),
                eyeColor:  color(0xE65100), patternColor: color(0xF9A825),
                patternType: .spotted,    bodyScale: .chonky, price: 400, isDefault: false),

        CatSkin(id: "emerald",           name: "Emerald",
                bodyColor: color(0x00695C), bellyColor: color(0x4DB6AC),
                eyeColor:  color(0xFFD740), patternColor: color(0x004D40),
                patternType: .marbled,    bodyScale: .normal, price: 475, isDefault: false),

        // ── Con accesorios ───────────────────────────────────────────────────
        CatSkin(id: "gentleman",  name: "Gentleman",
                bodyColor: color(0x1A1A2E), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x26C6DA), patternColor: color(0xFFD700),
                patternType: .tuxedo,     bodyScale: .slim,   price: 650, isDefault: false,
                accessory: .topHat,       accessoryColor: color(0x0D0D1A)),

        CatSkin(id: "king",       name: "King",
                bodyColor: color(0xB8860B), bellyColor: color(0xFFD700),
                eyeColor:  color(0x1A237E), patternColor: color(0xE53935),
                patternType: .marbled,    bodyScale: .chonky, price: 750, isDefault: false,
                accessory: .crownGold,    accessoryColor: color(0xFFD700)),

        CatSkin(id: "princess",   name: "Princess",
                bodyColor: color(0xF8BBD0), bellyColor: color(0xFCE4EC),
                eyeColor:  color(0xAD1457), patternColor: color(0xF06292),
                patternType: .solid,      bodyScale: .normal, price: 700, isDefault: false,
                accessory: .crownGem,     accessoryColor: color(0xFFD700)),

        CatSkin(id: "pirate",     name: "Pirate",
                bodyColor: color(0x4E342E), bellyColor: color(0xD7CCC8),
                eyeColor:  color(0xF44336), patternColor: color(0x1A0000),
                patternType: .spotted,    bodyScale: .normal, price: 550, isDefault: false,
                accessory: .piratePatch,  accessoryColor: color(0x1A0000)),

        CatSkin(id: "witch",      name: "Witch",
                bodyColor: color(0x1A1A2E), bellyColor: color(0x2D2D44),
                eyeColor:  color(0x00E676), patternColor: color(0x7B1FA2),
                patternType: .solid,      bodyScale: .slim,   price: 600, isDefault: false,
                accessory: .witchHat,     accessoryColor: color(0x1A1A2E)),

        CatSkin(id: "cowboy",     name: "Cowboy",
                bodyColor: color(0xC9A96E), bellyColor: color(0xF0DCBA),
                eyeColor:  color(0x5D4037), patternColor: color(0x8B5A2B),
                patternType: .tabby,      bodyScale: .normal, price: 500, isDefault: false,
                accessory: .cowboyHat,    accessoryColor: color(0x8B4513)),

        CatSkin(id: "viking",     name: "Viking",
                bodyColor: color(0xB0BEC5), bellyColor: color(0xECEFF1),
                eyeColor:  color(0xFF6F00), patternColor: color(0xCFD8DC),
                patternType: .solid,      bodyScale: .chonky, price: 650, isDefault: false,
                accessory: .vikingHelmet, accessoryColor: color(0x78909C)),

        CatSkin(id: "dj",         name: "DJ",
                bodyColor: color(0x212121), bellyColor: color(0x424242),
                eyeColor:  color(0xFF4081), patternColor: color(0xFF4081),
                patternType: .solid,      bodyScale: .normal, price: 575, isDefault: false,
                accessory: .headphones,   accessoryColor: color(0xFF4081)),

        CatSkin(id: "rocker",     name: "Rocker",
                bodyColor: color(0x4A0080), bellyColor: color(0x7B1FA2),
                eyeColor:  color(0xFF6D00), patternColor: color(0xFF6D00),
                patternType: .solid,      bodyScale: .normal, price: 575, isDefault: false,
                accessory: .headphones,   accessoryColor: color(0xFF6D00)),

        CatSkin(id: "angel",      name: "Angel",
                bodyColor: color(0xFFFDE7), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x42A5F5), patternColor: color(0xFFD740),
                patternType: .solid,      bodyScale: .normal, price: 550, isDefault: false,
                accessory: .halo,         accessoryColor: color(0xFFD740)),

        CatSkin(id: "alien",      name: "Alien",
                bodyColor: color(0x69F0AE), bellyColor: color(0xB9F6CA),
                eyeColor:  color(0x00BFA5), patternColor: color(0xFF4081),
                patternType: .solid,      bodyScale: .slim,   price: 600, isDefault: false,
                accessory: .alienAntenna, accessoryColor: color(0x00BFA5)),

        CatSkin(id: "robot",      name: "Robot",
                bodyColor: color(0x78909C), bellyColor: color(0xB0BEC5),
                eyeColor:  color(0x00BCD4), patternColor: color(0xCFD8DC),
                patternType: .solid,      bodyScale: .normal, price: 525, isDefault: false,
                accessory: .antenna,      accessoryColor: color(0x00BCD4)),

        CatSkin(id: "nerd",       name: "Nerd",
                bodyColor: color(0xFFF9C4), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x5C6BC0), patternColor: color(0x5C6BC0),
                patternType: .solid,      bodyScale: .normal, price: 450, isDefault: false,
                accessory: .glasses,      accessoryColor: color(0x3E2723)),

        CatSkin(id: "hipster",    name: "Hipster",
                bodyColor: color(0x8D6E63), bellyColor: color(0xD7CCC8),
                eyeColor:  color(0x4E342E), patternColor: color(0xA1887F),
                patternType: .marbled,    bodyScale: .slim,   price: 500, isDefault: false,
                accessory: .glasses,      accessoryColor: color(0x4E342E)),

        CatSkin(id: "cyberpunk",  name: "Cyberpunk",
                bodyColor: color(0x0D0D0D), bellyColor: color(0x1A1A1A),
                eyeColor:  color(0x39FF14), patternColor: color(0xFF006E),
                patternType: .tabby,      bodyScale: .slim,   price: 650, isDefault: false,
                accessory: .sunglasses,   accessoryColor: color(0xFF006E)),

        CatSkin(id: "detective",  name: "Detective",
                bodyColor: color(0x795548), bellyColor: color(0xD7CCC8),
                eyeColor:  color(0x5C6BC0), patternColor: color(0xFFD700),
                patternType: .solid,      bodyScale: .normal, price: 500, isDefault: false,
                accessory: .monocle,      accessoryColor: color(0xFFD700)),

        CatSkin(id: "cool_kid",   name: "Cool Kid",
                bodyColor: color(0xFF8F00), bellyColor: color(0xFFCC80),
                eyeColor:  color(0x1565C0), patternColor: color(0xFFFFFF),
                patternType: .solid,      bodyScale: .normal, price: 475, isDefault: false,
                accessory: .cap,          accessoryColor: color(0x1565C0)),

        CatSkin(id: "beanie_cat", name: "Beanie Cat",
                bodyColor: color(0x42A5F5), bellyColor: color(0xBBDEFB),
                eyeColor:  color(0xFFB300), patternColor: color(0xFFFFFF),
                patternType: .solid,      bodyScale: .chonky, price: 450, isDefault: false,
                accessory: .beanie,       accessoryColor: color(0xEF5350)),

        CatSkin(id: "diva",       name: "Diva",
                bodyColor: color(0xFF4DB8), bellyColor: color(0xFF99DD),
                eyeColor:  color(0xCC0077), patternColor: color(0xFF0066),
                patternType: .solid,      bodyScale: .chonky, price: 600, isDefault: false,
                accessory: .ribbon,       accessoryColor: color(0xFF0066)),

        CatSkin(id: "classy",     name: "Classy",
                bodyColor: color(0xF5F5F5), bellyColor: color(0xFFFFFF),
                eyeColor:  color(0x1565C0), patternColor: color(0xE53935),
                patternType: .tuxedo,     bodyScale: .normal, price: 550, isDefault: false,
                accessory: .bowtie,       accessoryColor: color(0xE53935)),
    ]

    static let ORANGE = getById("classic_orange")

    static func getById(_ id: String) -> CatSkin {
        all.first { $0.id == id } ?? all[0]
    }
}
