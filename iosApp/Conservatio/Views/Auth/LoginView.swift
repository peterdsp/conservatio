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
        VStack(spacing: 0) {
            Spacer()

            // Logo (coat of arms, transparent background)
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Text("Conservatio")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.conservatioPrimary)
                .padding(.top, 12)

            Text("Document heritage. Protect history.")
                .font(.conservatioBodySmall)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
                .padding(.bottom, 32)

            // Form
            VStack(spacing: 10) {
                if isRegistering {
                    TextField("Full Name", text: $name)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                        .textContentType(.name)
                        .autocorrectionDisabled()
                        .font(.system(size: 15))
                }

                TextField("Email", text: $email)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .font(.system(size: 15))

                SecureField("Password", text: $password)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    .textContentType(isRegistering ? .newPassword : .password)
                    .font(.system(size: 15))

                if let error = errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await authenticate() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else {
                        Text(isRegistering ? "Create Account" : "Sign In")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .background(
                    (email.isEmpty || password.isEmpty || isLoading)
                    ? Color.gray.opacity(0.3)
                    : Color.conservatioPrimary
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                Button {
                    withAnimation { isRegistering.toggle() }
                    errorMessage = nil
                } label: {
                    Text(isRegistering ? "Already have an account? Sign In" : "New here? Create Account")
                        .font(.caption)
                        .foregroundStyle(Color.conservatioPrimary)
                }
            }
            .padding(.horizontal, 40)

            // Divider
            HStack(spacing: 12) {
                Rectangle().frame(height: 0.5).foregroundStyle(.quaternary)
                Text("or continue with")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Rectangle().frame(height: 0.5).foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)

            // Social login (icon-only, compact)
            HStack(spacing: 16) {
                // Apple
                Button {
                    triggerAppleSignIn()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                        Image(systemName: "apple.logo")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 56, height: 44)
                }

                // Google
                Button {
                    Task { await signInWithGoogle() }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                            )
                        Text("G")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.blue)
                    }
                    .frame(width: 56, height: 44)
                }
            }

            Spacer()

            // Offline
            Button {
                onSuccess()
            } label: {
                Text("Continue Offline")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 28)
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
            errorMessage = "Could not connect. Check your network or continue offline."
        }
        isLoading = false
    }

    private func triggerAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate { result in
            handleAppleSignIn(result)
        }
        controller.delegate = delegate
        // Keep delegate alive
        objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        controller.performRequests()
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
            let userId = credential.user
            let email = credential.email
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }.joined(separator: " ")
            let idToken = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
            Task {
                isLoading = true
                do {
                    try await apiClient.socialLogin(
                        provider: "apple", providerUserId: userId,
                        email: email, name: fullName.isEmpty ? nil : fullName, idToken: idToken
                    )
                    onSuccess()
                } catch {
                    errorMessage = "Apple sign in failed. Try email or continue offline."
                }
                isLoading = false
            }
        case .failure:
            break
        }
    }

    private func signInWithGoogle() async {
        errorMessage = "Google sign in coming soon."
    }
}

// MARK: - Apple Sign In Delegate

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    let completion: (Result<ASAuthorization, Error>) -> Void

    init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        completion(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
}
