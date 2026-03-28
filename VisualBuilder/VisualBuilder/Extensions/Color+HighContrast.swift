import SwiftUI

extension Color {
    // MARK: - Core Palette (High Contrast Optimized)

    /// Primary accent color - bright blue
    static let vbAccent = Color(hex: "#4FC3F7")

    /// Background - very dark
    static let vbBackground = Color(hex: "#0D1117")

    /// Background dark variant
    static let vbBackgroundDark = Color(hex: "#010409")

    /// Surface - slightly lighter than background for cards/panels
    static let vbSurface = Color(hex: "#161B22")

    /// Primary text - high contrast white
    static let vbText = Color(hex: "#F0F6FC")

    /// Secondary text - muted but still readable
    static let vbTextSecondary = Color(hex: "#8B949E")

    // MARK: - Game Colors

    /// Success / Free Play green
    static let vbGreen = Color(hex: "#3FB950")

    /// Warning / Challenge orange
    static let vbOrange = Color(hex: "#F0883E")

    /// Danger / Timer red
    static let vbRed = Color(hex: "#F85149")

    /// Info / Timer blue
    static let vbBlue = Color(hex: "#58A6FF")

    /// Easter egg / Special purple
    static let vbPurple = Color(hex: "#BC8CFF")

    /// Star / Achievement yellow
    static let vbYellow = Color(hex: "#F2CC60")

    // MARK: - Piece Colors (High Contrast Set)

    /// Bright accessible colors for building pieces
    static let vbPieceRed = Color(hex: "#FF6B6B")
    static let vbPieceBlue = Color(hex: "#4DABF7")
    static let vbPieceGreen = Color(hex: "#69DB7C")
    static let vbPieceYellow = Color(hex: "#FFD43B")
    static let vbPieceOrange = Color(hex: "#FF922B")
    static let vbPiecePurple = Color(hex: "#CC5DE8")
    static let vbPiecePink = Color(hex: "#F06595")
    static let vbPieceTeal = Color(hex: "#38D9A9")

    // MARK: - Hex Initializer

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
