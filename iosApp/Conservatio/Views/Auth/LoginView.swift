import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    var apiClient: APIClient
    var onSuccess: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Logo
            VStack(spacing: 12) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.conservatioPrimary)

                Text("Conservatio")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.conservatioPrimary)

                Text("Document heritage. Protect history.")
                    .font(.conservatioBodyMedium)
                    .foregroundStyle(.secondary)
            }

            // Form
            VStack(spacing: 16) {
                if isRegistering {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                }

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(isRegistering ? .newPassword : .password)

                if let error = errorMessage {
                    Text(error)
                        .font(.conservatioBodySmall)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await authenticate() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    } else {
                        Text(isRegistering ? "Create Account" : "Sign In")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.conservatioPrimary)
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                Button {
                    withAnimation { isRegistering.toggle() }
                    errorMessage = nil
                } label: {
                    Text(isRegistering ? "Already have an account? Sign In" : "New here? Create Account")
                        .font(.conservatioBodySmall)
                        .foregroundStyle(Color.conservatioPrimary)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            // Offline mode
            Button {
                onSuccess()
            } label: {
                Text("Continue Offline")
                    .font(.conservatioLabelMedium)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 24)
        }
        .background(Color.conservatioBackground)
    }

    private func authenticate() async {
        isLoading = true
        errorMessage = nil

        do {
            if isRegistering {
                try await apiClient.register(email: email, password: password, name: name)
            } else {
                try await apiClient.login(email: email, password: password)
            }
            onSuccess()
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Could not connect to server. Check your network or continue offline."
        }

        isLoading = false
    }
}
