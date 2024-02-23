//
//  AuthViewModel.swift
//  CoLiving
//
//  Created by Gordon on 14.12.22.
//

import Foundation
import AuthenticationServices
import Combine
import JWTDecode
import GordonKirschAPI
import GordonKirschUtils
import PushNotifications

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signup
}

class AuthenticatedViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var showLoginScreen = false
    @Published var toast: Toast?
    
    @Published var currentUser: User?
    
    @Published var email = ""
    @Published var password = ""
    
    @Published var authError = ""
    
    private var currentNonce: String?
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func checkAccessToken() {
        self.authenticationState = API.shared.hasAccessToken() ? .authenticated : .unauthenticated
        
        if self.authenticationState == .authenticated {
            onAuthenticated()
        }
    }
    
    func onAuthenticated() {
        do {
            let jwt = try decode(jwt: KeychainStorage.shared.getAccessToken().token)

            let tokenProvider = BeamsTokenProvider(authURL: "\(API.shared.getBaseUrl())/beamer/token") { () -> AuthData in
                let sessionToken = KeychainStorage.shared.getAccessToken().token
                let headers = ["Authorization": "Bearer \(sessionToken)"]
                let queryParams: [String: String] = [:]
                return AuthData(headers: headers, queryParams: queryParams)
            }
            
            
            
            PushNotifications.shared.setUserId(jwt.uuid.uuidString, tokenProvider: tokenProvider, completion: { error in
                guard error == nil else {
                    print(error.debugDescription)
                    return
                }

                print("Successfully authenticated with Pusher Beams")
            })
        } catch {
            print(error)
        }
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce

        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            print(failure)
        }
        else if case .success(let success) = result {
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let _ = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                Task {
                    let result = await API.shared.login(withIDToken: idTokenString, fromProvider: "apple")
                    await MainActor.run {
                        self.handleLoginResponse(result)
                    }
                }
            }
        }
    }

    func handleGoogleSignIn() {
        handleThirdPartySignIn(withProvider: "google")
    }
    
    func handleThirdPartySignIn(withProvider provider: String) {
        let url = API.shared.generateConnectUrl(forProvider: provider, redirectTo: "coliving://oauth-callback")
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "coliving") { callbackUrl, error in
            if let error {
                print(error)
                return
            }
            
            guard let callbackUrl else { return }
            
            let result = API.shared.login(fromURL: callbackUrl)
            
            self.handleLoginResponse(result)
        }
        
        session.presentationContextProvider = self
        session.start()
    }
    
    @MainActor
    func login() async {
        authError = ""
        
        let result = await API.shared.login(email: email, password: password)
        
        handleLoginResponse(result)
    }
    
    @MainActor
    func register() async {
        authError = ""
        
        let result = await API.shared.register(email: email, password: password)
        
        handleLoginResponse(result)
    }
    
    func handleLoginResponse(_ response: ApiResult<LoginResponse>) {
        switch response {
        case .success(_):
            authenticationState = .authenticated
            email = ""
            password = ""
            authError = ""
            
            onAuthenticated()
            break;
        case .serverError(let error):
            if error.message == Errors.ERR_WRONG_CREDENTIALS {
                authError = "The username or password you entered is incorrect"
            } else {
                toast = Toast.from(response: response)
            }
            break;
        default:
            toast = Toast.from(response: response)
            break;
        }
    }
    
    func logout() async {
        PushNotifications.shared.clearAllState {
            PushNotifications.shared.start(instanceId: Bundle.main.infoDictionary?["PUSHER_INSTANCE_ID"] as! String)
        }
        await API.shared.logout()
        await MainActor.run {
            self.authenticationState = .unauthenticated
        }
    }
}
