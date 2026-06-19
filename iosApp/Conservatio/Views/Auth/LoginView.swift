import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var pendingProvider: String?

    var apiClient: APIClient
    var onSuccess: () -> Void

    var body: some View {
        ZStack {
            // Ambient peach/blue/cream backdrop  --  same language as web.
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.96, blue: 0.94),
                    Color(red: 0.96, green: 0.91, blue: 0.88),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Soft radial highlights, peach + blue
            GeometryReader { proxy in
                Circle()
                    .fill(Color(red: 1.0, green: 0.77, blue: 0.65).opacity(0.45))
                    .frame(width: proxy.size.width * 0.9)
                    .blur(radius: 80)
                    .offset(x: -proxy.size.width * 0.35, y: -proxy.size.height * 0.3)
                Circle()
                    .fill(Color(red: 0.67, green: 0.77, blue: 0.86).opacity(0.45))
                    .frame(width: proxy.size.width * 0.8)
                    .blur(radius: 80)
                    .offset(x: proxy.size.width * 0.35, y: -proxy.size.height * 0.2)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo plaque in glass material
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 88, height: 88)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.55), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 24, y: 12)
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.conservatioPrimary)
                }

                Text("Conservatio")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.conservatioPrimary)
                    .padding(.top, 22)

                VStack(spacing: 10) {
                    OAuthProviderButton(
                        provider: .google,
                        isBusy: pendingProvider == "google"
                    ) {
                        Task { await beginOAuth(.google) }
                    }
                    OAuthProviderButton(
                        provider: .apple,
                        isBusy: pendingProvider == "apple"
                    ) {
                        beginAppleNative()
                    }
                    OAuthProviderButton(
                        provider: .github,
                        isBusy: pendingProvider == "github"
                    ) {
                        Task { await beginOAuth(.github) }
                    }
                }
                .padding(.top, 36)
                .padding(.horizontal, 32)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.horizontal, 32)
                }
                if isLoading && errorMessage == nil {
                    Text("Finishing sign-in…")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 12)
                }

                Spacer()
            }
        }
    }

    // MARK: - OAuth (web-based, via ASWebAuthenticationSession)

    private func beginOAuth(_ provider: OAuthProvider) async {
        guard !isLoading else { return }
        await MainActor.run {
            pendingProvider = provider.id
            errorMessage = nil
            isLoading = true
        }
        defer {
            Task { @MainActor in
                pendingProvider = nil
                isLoading = false
            }
        }
        do {
            let code = try await OAuthCoordinator.shared.run(provider: provider)
            try await apiClient.oauthExchange(
                provider: provider.id,
                code: code,
                redirectUri: provider.callbackURL
            )
            await MainActor.run { onSuccess() }
        } catch OAuthError.cancelled {
            // Silent  --  user closed the sheet
        } catch let error as APIError {
            await MainActor.run { errorMessage = error.errorDescription }
        } catch {
            await MainActor.run { errorMessage = "Sign-in failed. Try again." }
        }
    }

    // MARK: - Apple (native)

    private func beginAppleNative() {
        guard !isLoading else { return }
        pendingProvider = "apple"
        errorMessage = nil
        isLoading = true
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleSignInDelegate { result in
            self.handleAppleNative(result)
        }
        controller.delegate = delegate
        // Keep delegate alive
        objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        controller.performRequests()
    }

    private func handleAppleNative(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let idTokenData = credential.identityToken,
                let idToken = String(data: idTokenData, encoding: .utf8)
            else {
                Task { @MainActor in
                    errorMessage = "Apple sign-in returned no token."
                    isLoading = false
                    pendingProvider = nil
                }
                return
            }
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            Task {
                do {
                    try await apiClient.oauthApple(
                        identityToken: idToken,
                        email: credential.email,
                        fullName: fullName.isEmpty ? nil : fullName
                    )
                    await MainActor.run {
                        isLoading = false
                        pendingProvider = nil
                        onSuccess()
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Apple sign-in failed."
                        isLoading = false
                        pendingProvider = nil
                    }
                }
            }
        case .failure:
            Task { @MainActor in
                isLoading = false
                pendingProvider = nil
            }
        }
    }
}

// MARK: - Provider model

enum OAuthProvider {
    case google
    case apple
    case github

    var id: String {
        switch self {
        case .google: return "google"
        case .apple: return "apple"
        case .github: return "github"
        }
    }

    var title: String {
        switch self {
        case .google: return "Continue with Google"
        case .apple: return "Continue with Apple"
        case .github: return "Continue with GitHub"
        }
    }

    var clientId: String {
        switch self {
        case .google: return "877268079515-bdcjldgs1mdqmjdkatsl8cg46nimd1og.apps.googleusercontent.com"
        case .apple: return "dev.peterdsp.conservatio.web"
        case .github: return "Ov23liW3UmdSJ76Cn2ov"
        }
    }

    var authorizeURL: String {
        switch self {
        case .google: return "https://accounts.google.com/o/oauth2/v2/auth"
        case .apple: return "https://appleid.apple.com/auth/authorize"
        case .github: return "https://github.com/login/oauth/authorize"
        }
    }

    var scope: String {
        switch self {
        case .google: return "openid email profile"
        case .apple: return "name email"
        case .github: return "read:user user:email"
        }
    }

    /// Custom URL scheme registered in Info.plist:
    ///   CFBundleURLSchemes: ["conservatio"]
    /// Provider OAuth apps must whitelist this exact value as a redirect URI.
    var callbackURL: String { "conservatio://oauth-callback/\(id)" }
}

// MARK: - Web OAuth coordinator (ASWebAuthenticationSession)

enum OAuthError: Error {
    case cancelled
    case missingCode
    case unsupported
}

@MainActor
final class OAuthCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = OAuthCoordinator()

    func run(provider: OAuthProvider) async throws -> String {
        let state = UUID().uuidString
        var components = URLComponents(string: provider.authorizeURL)!
        var items: [URLQueryItem] = [
            .init(name: "client_id", value: provider.clientId),
            .init(name: "redirect_uri", value: provider.callbackURL),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: provider.scope),
            .init(name: "state", value: state),
        ]
        if provider.id == "apple" {
            items.append(.init(name: "response_mode", value: "fragment"))
        }
        components.queryItems = items
        guard let url = components.url else { throw OAuthError.unsupported }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "conservatio"
            ) { callbackURL, error in
                if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    continuation.resume(throwing: OAuthError.cancelled)
                    return
                }
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: OAuthError.cancelled)
                    return
                }
                let comps = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
                let fragmentItems = (comps?.fragment ?? "")
                    .split(separator: "&")
                    .compactMap { pair -> URLQueryItem? in
                        let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                        guard parts.count == 2 else { return nil }
                        return URLQueryItem(name: parts[0], value: parts[1].removingPercentEncoding ?? parts[1])
                    }
                let allItems = (comps?.queryItems ?? []) + fragmentItems
                guard let code = allItems.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: OAuthError.missingCode)
                    return
                }
                continuation.resume(returning: code)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? ASPresentationAnchor()
    }
}

// MARK: - OAuth provider button

private struct OAuthProviderButton: View {
    let provider: OAuthProvider
    let isBusy: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                providerGlyph
                Text(provider.title)
                    .font(.system(size: 15, weight: .semibold))
                if isBusy {
                    ProgressView().tint(.primary).padding(.leading, 6)
                }
            }
            .foregroundStyle(Color.conservatioText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, y: 6)
        }
        .disabled(isBusy)
    }

    @ViewBuilder
    private var providerGlyph: some View {
        switch provider {
        case .google:
            // Simple G mark
            Text("G")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(LinearGradient(
                    colors: [.red, .yellow, .green, .blue],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
        case .apple:
            Image(systemName: "applelogo")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.black)
        case .github:
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
        }
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
