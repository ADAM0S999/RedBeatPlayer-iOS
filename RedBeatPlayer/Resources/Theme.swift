import SwiftUI

extension Color {
    // Primary Red & Black Palette
    static let redPrimary = Color(hex: 0xE53935)
    static let redDark = Color(hex: 0xB71C1C)
    static let redAccent = Color(hex: 0xFF1744)
    static let redLight = Color(hex: 0xFF6F60)

    static let blackBg = Color(hex: 0x0A0A0A)
    static let blackSurface = Color(hex: 0x141414)
    static let blackCard = Color(hex: 0x1C1C1C)
    static let blackElevated = Color(hex: 0x242424)
    static let blackDivider = Color(hex: 0x2A2A2A)

    static let whitePrimary = Color.white
    static let whiteSecondary = Color.white.opacity(0.7)
    static let whiteDisabled = Color.white.opacity(0.38)

    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct DeveloperConstants {
    static let name = "LM7BOS"
    static let instagramHandle = "@LM7BOS"
    static let instagramURL = URL(string: "https://instagram.com/LM7BOS")!
}
