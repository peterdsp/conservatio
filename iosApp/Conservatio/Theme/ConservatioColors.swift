import SwiftUI
import UIKit

// One palette for the app, the website and the store: frost ground, slate
// ink, one verdigris accent. At night the same three roles swap ends: the
// ground goes to deep slate, the ink to frost, and the accent brightens to the
// mark's own square. The names below are kept from the first palette so every
// view compiles unchanged; what they point at is the shared system.
private func dynamic(_ light: UInt32, _ dark: UInt32) -> Color {
    func rgb(_ hex: UInt32) -> UIColor {
        UIColor(red: CGFloat((hex >> 16) & 0xff) / 255,
                green: CGFloat((hex >> 8) & 0xff) / 255,
                blue: CGFloat(hex & 0xff) / 255, alpha: 1)
    }
    return Color(UIColor { trait in trait.userInterfaceStyle == .dark ? rgb(dark) : rgb(light) })
}

extension Color {
    // Accent: verdigris, on the primary action and one detail per screen.
    static let conservatioPrimary = dynamic(0x0d7480, 0x3fb3a8)
    static let conservatioPrimaryLight = dynamic(0x3fb3a8, 0x6fcfc5)
    static let conservatioPrimaryDark = dynamic(0x095861, 0x2a9d94)

    // Ink does the work the second and third colours used to do.
    static let conservatioSecondary = dynamic(0x1f3038, 0xe9eef0)
    static let conservatioSecondaryLight = dynamic(0x5d6b72, 0x9aa8ae)
    static let conservatioSecondaryDark = dynamic(0x132026, 0xf7f9fa)
    static let conservatioTertiary = dynamic(0x5d6b72, 0x9aa8ae)

    // Ground and surfaces separate by a step in tone, never by a line or a shadow.
    static let conservatioBackground = dynamic(0xf7f9fa, 0x0f1a1e)
    static let conservatioSurface = dynamic(0xffffff, 0x16252b)
    static let conservatioSurfaceVariant = dynamic(0xecf0f2, 0x1c2d34)
    static let conservatioText = dynamic(0x1f3038, 0xe9eef0)
    static let conservatioTextSecondary = dynamic(0x5d6b72, 0x9aa8ae)

    // Condition ratings: ink for the sound end of the scale, one amber for
    // attention, one red for critical. Two hues, not five, so the rating
    // reads as a word beside a gauge rather than as a traffic light.
    static let conditionExcellent = dynamic(0x1f3038, 0xe9eef0)
    static let conditionGood = dynamic(0x5d6b72, 0x9aa8ae)
    static let conditionFair = dynamic(0xb06f12, 0xd9a04a)
    static let conditionPoor = dynamic(0x9b2c2c, 0xd96b6b)
    static let conditionCritical = dynamic(0x7a1f1f, 0xc24a4a)
}
