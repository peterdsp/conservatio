import SwiftUI
import AuthenticationServices

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
        VStack(spacing: 24) {
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

            // Social login buttons
            VStack(spacing: 12) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(12)

                Button {
                    Task { await signInWithGoogle() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "g.circle.fill")
                            .font(.title3)
                        Text("Sign in with Google")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .foregroundStyle(.primary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 32)

            // Divider
            HStack {
                Rectangle().frame(height: 1).foregroundStyle(.quaternary)
                Text("or")
                    .font(.conservatioLabelMedium)
                    .foregroundStyle(.secondary)
                Rectangle().frame(height: 1).foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 32)

            // Email/password form
            VStack(spacing: 14) {
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

    // MARK: - Email/Password Auth

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

    // MARK: - Sign in with Apple

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

            let userId = credential.user
            let email = credential.email
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            let identityToken = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }

            Task {
                isLoading = true
                do {
                    try await apiClient.socialLogin(
                        provider: "apple",
                        providerUserId: userId,
                        email: email,
                        name: fullName.isEmpty ? nil : fullName,
                        idToken: identityToken
                    )
                    onSuccess()
                } catch {
                    errorMessage = "Apple sign in failed. Try email/password or continue offline."
                }
                isLoading = false
            }

        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "Apple sign in was cancelled."
            }
        }
    }

    // MARK: - Sign in with Google

    private func signInWithGoogle() async {
        // TODO: integrate Google Sign-In SDK
        // For now, show a message
        errorMessage = "Google sign in coming soon. Use email/password or Apple."
    }
}
