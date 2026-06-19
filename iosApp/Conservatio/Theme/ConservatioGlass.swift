import SwiftUI

// MARK: - Ambient backdrop

/// The ambient peach + blue + cream radial gradient that sits behind every
/// glass surface in the Conservatio design language. Drops in as a
/// background view; safe to compose under any content.
struct ConservatioAmbientBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.96, blue: 0.94),
                    Color(red: 0.96, green: 0.91, blue: 0.88),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { proxy in
                Circle()
                    .fill(Color(red: 1.0, green: 0.77, blue: 0.65).opacity(0.40))
                    .frame(width: proxy.size.width * 0.95)
                    .blur(radius: 90)
                    .offset(x: -proxy.size.width * 0.4, y: -proxy.size.height * 0.3)
                Circle()
                    .fill(Color(red: 0.67, green: 0.77, blue: 0.86).opacity(0.38))
                    .frame(width: proxy.size.width * 0.85)
                    .blur(radius: 90)
                    .offset(x: proxy.size.width * 0.4, y: -proxy.size.height * 0.15)
                Circle()
                    .fill(Color(red: 1.0, green: 0.88, blue: 0.78).opacity(0.30))
                    .frame(width: proxy.size.width * 0.9)
                    .blur(radius: 100)
                    .offset(x: 0, y: proxy.size.height * 0.45)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass shape modifiers

/// Applies the standard Conservatio liquid-glass material: translucent fill,
/// soft inset white ring, a top specular highlight, and a low diffused
/// shadow. Use on any container view.
struct GlassPanelStyle: ViewModifier {
    var cornerRadius: CGFloat = 24
    var tint: Color = .white

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    LinearGradient(
                        colors: [tint.opacity(0.55), tint.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 22, x: 0, y: 14)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}

extension View {
    /// Shorthand for the standard glass panel material.
    func glassPanel(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassPanelStyle(cornerRadius: cornerRadius))
    }

    /// Same material but tinted darker, used for accent panels on light
    /// backgrounds (e.g. the "storage" card on the dashboard).
    func glassPanelDark(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassPanelStyle(cornerRadius: cornerRadius, tint: Color.black))
    }

    /// Slightly tighter glass for inline pieces: search bars, chips, small
    /// info badges.
    func glassChip() -> some View {
        modifier(GlassPanelStyle(cornerRadius: 14))
    }
}

// MARK: - Glass buttons

/// The primary "fill me with terracotta" CTA button: gradient fill, white
/// inset ring, tinted shadow.
struct GlassButtonPrimaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [Color.conservatioPrimary, Color.conservatioPrimaryDark],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(
                color: Color.conservatioPrimary.opacity(0.45),
                radius: configuration.isPressed ? 6 : 16,
                x: 0,
                y: configuration.isPressed ? 2 : 10
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Secondary glass-on-glass button: translucent white, terracotta text.
struct GlassButtonSecondaryStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color.conservatioText)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonPrimaryStyle {
    /// Conservatio's primary CTA button style.
    static var glassPrimary: GlassButtonPrimaryStyle { GlassButtonPrimaryStyle() }
}

extension ButtonStyle where Self == GlassButtonSecondaryStyle {
    /// Conservatio's secondary glass button style.
    static var glassSecondary: GlassButtonSecondaryStyle { GlassButtonSecondaryStyle() }
}

// MARK: - Glass list row

/// Translucent row used inside lists and cards instead of the default
/// `Color.white` fill, so list content stays consistent with the rest of
/// the glass language.
struct GlassListRowBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            .padding(.vertical, 4)
    }
}

// MARK: - Glass text field

/// Translucent text field background, used for inputs across the app. Use
/// in combination with `TextField` / `SecureField` like:
///
///     TextField("Email", text: $email).glassField()
extension View {
    func glassField() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}
