import SwiftUI

struct ComingSoonView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "hammer.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.conservatioTertiary)

            Text("Coming Soon")
                .font(.conservatioHeadlineSmall)

            Text(description)
                .font(.conservatioBodyMedium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .navigationTitle(title)
    }
}
