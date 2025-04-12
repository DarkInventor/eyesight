import SwiftUI

enum ThemeStyle: String, CaseIterable, Identifiable {
    case minimal = "Minimal"
    case ocean = "Ocean"
    case forest = "Forest"
    case sunset = "Sunset"
    case lavender = "Lavender"
    case nord = "Nord"
    case mocha = "Mocha"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .minimal: return "Clean black & white design"
        case .ocean: return "Calming blue tones"
        case .forest: return "Soothing natural greens"
        case .sunset: return "Warm, relaxing colors"
        case .lavender: return "Gentle purple hues"
        case .nord: return "Arctic, bluish colors"
        case .mocha: return "Warm, coffee-inspired tones"
        }
    }
}

struct ThemeColors {
    let background: Color
    let foreground: Color
    let muted: Color
    let mutedBackground: Color
    let accent: Color
    let accentForeground: Color
    let buttonHover: Color
    let buttonActive: Color
    let textPrimary: Color
    let textSecondary: Color
    let border: Color
    let progressBackground: Color
    let progressForeground: Color
    let success: Color
    let warning: Color
}

enum Theme {
    static func colors(for style: ThemeStyle) -> ThemeColors {
        switch style {
        case .minimal:
            return ThemeColors(
                background: .black,
                foreground: .white,
                muted: Color(white: 0.65),
                mutedBackground: Color(white: 0.15),
                accent: .white,
                accentForeground: .black,
                buttonHover: Color(white: 0.2),
                buttonActive: Color(white: 0.25),
                textPrimary: .white,
                textSecondary: Color(white: 0.65),
                border: Color(white: 0.2),
                progressBackground: Color(white: 0.15),
                progressForeground: .white,
                success: Color.green,
                warning: Color.orange
            )
        case .ocean:
            return ThemeColors(
                background: Color(red: 0.06, green: 0.12, blue: 0.22),
                foreground: Color(red: 0.85, green: 0.95, blue: 1.0),
                muted: Color(red: 0.6, green: 0.75, blue: 0.85),
                mutedBackground: Color(red: 0.1, green: 0.18, blue: 0.3),
                accent: Color(red: 0.4, green: 0.8, blue: 1.0),
                accentForeground: .black,
                buttonHover: Color(red: 0.15, green: 0.25, blue: 0.4),
                buttonActive: Color(red: 0.2, green: 0.3, blue: 0.45),
                textPrimary: Color(red: 0.85, green: 0.95, blue: 1.0),
                textSecondary: Color(red: 0.6, green: 0.75, blue: 0.85),
                border: Color(red: 0.2, green: 0.3, blue: 0.4),
                progressBackground: Color(red: 0.1, green: 0.18, blue: 0.3),
                progressForeground: Color(red: 0.4, green: 0.8, blue: 1.0),
                success: Color(red: 0.3, green: 0.8, blue: 0.6),
                warning: Color(red: 1.0, green: 0.6, blue: 0.4)
            )
        case .forest:
            return ThemeColors(
                background: Color(red: 0.05, green: 0.15, blue: 0.1),
                foreground: Color(red: 0.85, green: 1.0, blue: 0.9),
                muted: Color(red: 0.6, green: 0.8, blue: 0.7),
                mutedBackground: Color(red: 0.1, green: 0.25, blue: 0.15),
                accent: Color(red: 0.3, green: 0.9, blue: 0.5),
                accentForeground: .black,
                buttonHover: Color(red: 0.15, green: 0.35, blue: 0.2),
                buttonActive: Color(red: 0.2, green: 0.4, blue: 0.25),
                textPrimary: Color(red: 0.85, green: 1.0, blue: 0.9),
                textSecondary: Color(red: 0.6, green: 0.8, blue: 0.7),
                border: Color(red: 0.2, green: 0.4, blue: 0.3),
                progressBackground: Color(red: 0.1, green: 0.25, blue: 0.15),
                progressForeground: Color(red: 0.3, green: 0.9, blue: 0.5),
                success: Color(red: 0.2, green: 0.8, blue: 0.4),
                warning: Color(red: 0.9, green: 0.6, blue: 0.3)
            )
        case .sunset:
            return ThemeColors(
                background: Color(red: 0.15, green: 0.08, blue: 0.12),
                foreground: Color(red: 1.0, green: 0.9, blue: 0.85),
                muted: Color(red: 0.85, green: 0.6, blue: 0.65),
                mutedBackground: Color(red: 0.25, green: 0.12, blue: 0.18),
                accent: Color(red: 1.0, green: 0.4, blue: 0.4),
                accentForeground: .white,
                buttonHover: Color(red: 0.35, green: 0.15, blue: 0.25),
                buttonActive: Color(red: 0.4, green: 0.2, blue: 0.3),
                textPrimary: Color(red: 1.0, green: 0.9, blue: 0.85),
                textSecondary: Color(red: 0.85, green: 0.6, blue: 0.65),
                border: Color(red: 0.4, green: 0.2, blue: 0.3),
                progressBackground: Color(red: 0.25, green: 0.12, blue: 0.18),
                progressForeground: Color(red: 1.0, green: 0.4, blue: 0.4),
                success: Color(red: 0.6, green: 0.8, blue: 0.4),
                warning: Color(red: 1.0, green: 0.6, blue: 0.3)
            )
        case .lavender:
            return ThemeColors(
                background: Color(red: 0.12, green: 0.1, blue: 0.18),
                foreground: Color(red: 0.95, green: 0.9, blue: 1.0),
                muted: Color(red: 0.75, green: 0.7, blue: 0.85),
                mutedBackground: Color(red: 0.18, green: 0.15, blue: 0.28),
                accent: Color(red: 0.7, green: 0.4, blue: 1.0),
                accentForeground: .white,
                buttonHover: Color(red: 0.25, green: 0.2, blue: 0.35),
                buttonActive: Color(red: 0.3, green: 0.25, blue: 0.4),
                textPrimary: Color(red: 0.95, green: 0.9, blue: 1.0),
                textSecondary: Color(red: 0.75, green: 0.7, blue: 0.85),
                border: Color(red: 0.3, green: 0.25, blue: 0.4),
                progressBackground: Color(red: 0.18, green: 0.15, blue: 0.28),
                progressForeground: Color(red: 0.7, green: 0.4, blue: 1.0),
                success: Color(red: 0.5, green: 0.8, blue: 0.5),
                warning: Color(red: 0.9, green: 0.6, blue: 0.4)
            )
        case .nord:
            return ThemeColors(
                background: Color(red: 0.18, green: 0.20, blue: 0.25),
                foreground: Color(red: 0.92, green: 0.93, blue: 0.95),
                muted: Color(red: 0.73, green: 0.78, blue: 0.82),
                mutedBackground: Color(red: 0.23, green: 0.26, blue: 0.32),
                accent: Color(red: 0.57, green: 0.71, blue: 0.78),
                accentForeground: .black,
                buttonHover: Color(red: 0.28, green: 0.31, blue: 0.37),
                buttonActive: Color(red: 0.33, green: 0.36, blue: 0.42),
                textPrimary: Color(red: 0.92, green: 0.93, blue: 0.95),
                textSecondary: Color(red: 0.73, green: 0.78, blue: 0.82),
                border: Color(red: 0.28, green: 0.31, blue: 0.37),
                progressBackground: Color(red: 0.23, green: 0.26, blue: 0.32),
                progressForeground: Color(red: 0.57, green: 0.71, blue: 0.78),
                success: Color(red: 0.63, green: 0.75, blue: 0.63),
                warning: Color(red: 0.92, green: 0.69, blue: 0.53)
            )
        case .mocha:
            return ThemeColors(
                background: Color(red: 0.15, green: 0.12, blue: 0.10),
                foreground: Color(red: 0.95, green: 0.90, blue: 0.85),
                muted: Color(red: 0.75, green: 0.65, blue: 0.60),
                mutedBackground: Color(red: 0.20, green: 0.16, blue: 0.14),
                accent: Color(red: 0.85, green: 0.60, blue: 0.45),
                accentForeground: .white,
                buttonHover: Color(red: 0.25, green: 0.20, blue: 0.18),
                buttonActive: Color(red: 0.30, green: 0.25, blue: 0.22),
                textPrimary: Color(red: 0.95, green: 0.90, blue: 0.85),
                textSecondary: Color(red: 0.75, green: 0.65, blue: 0.60),
                border: Color(red: 0.30, green: 0.25, blue: 0.22),
                progressBackground: Color(red: 0.20, green: 0.16, blue: 0.14),
                progressForeground: Color(red: 0.85, green: 0.60, blue: 0.45),
                success: Color(red: 0.60, green: 0.75, blue: 0.55),
                warning: Color(red: 0.90, green: 0.65, blue: 0.45)
            )
        }
    }
    
    @AppStorage("selectedTheme") static var selectedStyle: ThemeStyle = .minimal
    
    static var current: ThemeColors {
        colors(for: selectedStyle)
    }
} 