//
//  CruOktaAuthentication.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 12/21/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import UIKit

public final class CruOktaAuthentication: OktaAuthentication {
    
    private static let defaultScopes: String = "openid profile offline_access email"
    private static let defaultPrompt: String = "login"
    
    public init(clientId: String, logoutRedirectUri: String, issuer: String, redirectUri: String) {
        
        super.init(configModel: OktaConfigModel(
            clientId: clientId,
            logoutRedirectUri: logoutRedirectUri,
            issuer: issuer,
            prompt: CruOktaAuthentication.defaultPrompt,
            redirectUri: redirectUri,
            scopes: CruOktaAuthentication.defaultScopes)
        )
    }
    
    @MainActor public func signIn(fromViewController: UIViewController, completion: @escaping ((_ response: OktaAuthenticationResponse) -> Void)) {
        
        super.authenticate(fromViewController: fromViewController, policy: .attemptToRenewAccessTokenElseSignInWithBrowser(shouldSignOutAndRetryAuthenticationIfAuthenticationFails: true), completion: completion)
    }
    
    @MainActor public func signOut(fromViewController: UIViewController, completion: @escaping ((_ signOutResponse: OktaSignOutResponse) -> Void)) {
        
        super.signOut(fromViewController: fromViewController, forceRemoveSecureStorageAndRevokeStateManager: true, completion: completion)
    }
    
    @MainActor public func getAuthorizedCruUser(completion: @escaping ((_ result: Result<CruOktaUser, OktaAuthenticationError>) -> Void)) {
        getAuthorizedCodableUser { (_ result: Result<CruOktaUser, OktaAuthenticationError>) in
            completion(result)
        }
    }
}
