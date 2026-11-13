import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.conservatioBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("Conservatio")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(Color.conservatioText)

                    Text("Document heritage. Protect history.")
                        .font(.conservatioBodyMedium)
                        .foregroundStyle(.secondary)
                }
                .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}
