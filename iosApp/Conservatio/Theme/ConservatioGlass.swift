import SwiftUI

// The surfaces of the app. The names date from a glass look that is gone:
// a panel is now a flat step in tone on the ground, with no material, no
// ring and no shadow at rest, which is how the website and the PDF already
// look. Keeping the names means no view had to change to follow.

// MARK: - Backdrop

/// The ground behind every screen. A flat colour: nothing drifts behind the content.
struct ConservatioAmbientBackground: View {
    var body: some View {
        Color.conservatioBackground.ignoresSafeArea()
    }
}

// MARK: - Panels

/// A container on the ground: one tone step up, continuous corners, nothing else.
struct GlassPanelStyle: ViewModifier {
    var cornerRadius: CGFloat = 16
    var tint: Color = .white

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tint == .black ? Color.conservatioSecondary : Color.conservatioSurfaceVariant)
            )
    }
}

extension View {
    /// A panel on the ground.
    func glassPanel(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassPanelStyle(cornerRadius: cornerRadius))
    }

    /// The one dark panel a screen may carry (the storage card on the dashboard).
    func glassPanelDark(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassPanelStyle(cornerRadius: cornerRadius, tint: Color.black))
    }

    /// Tighter corners for inline pieces: search fields, chips, small badges.
    func glassChip() -> some View {
        modifier(GlassPanelStyle(cornerRadius: 10))
    }
}

// MARK: - Buttons

/// The primary action: one flat fill of the accent, white label, a press that darkens.
struct GlassButtonPrimaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity)
            .background(
                configuration.isPressed ? Color.conservatioPrimaryDark : Color.conservatioPrimary,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// The secondary action: ink on a surface step, nothing more.
struct GlassButtonSecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.conservatioText)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(
                Color.conservatioSurfaceVariant.opacity(configuration.isPressed ? 0.7 : 1),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonPrimaryStyle {
    static var glassPrimary: GlassButtonPrimaryStyle { GlassButtonPrimaryStyle() }
}

extension ButtonStyle where Self == GlassButtonSecondaryStyle {
    static var glassSecondary: GlassButtonSecondaryStyle { GlassButtonSecondaryStyle() }
}

// MARK: - List row

/// A row inside a list or card: the surface step, no ring, no shadow.
struct GlassListRowBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.conservatioSurfaceVariant)
            .padding(.vertical, 4)
    }
}

// MARK: - Text field

/// A field: the surface step with comfortable padding.
extension View {
    func glassField() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(Color.conservatioSurfaceVariant, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
