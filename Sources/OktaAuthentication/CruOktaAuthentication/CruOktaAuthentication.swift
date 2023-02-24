//
//  CruOktaAuthentication.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 12/21/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import UIKit

public class CruOktaAuthentication: OktaAuthentication {
    
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
    
    public func signIn(fromViewController: UIViewController, completion: @escaping ((_ response: OktaAuthenticationResponse) -> Void)) {
        
        var numberOfSignInRetries: Int = 0
        
        super.renewAccessTokenElseAuthenticate(fromViewController: fromViewController) { [weak self] (response: OktaAuthenticationResponse) in
            
            switch response.result {
           
            case .success( _):
                break
            
            case .failure( _):
                
                let shouldSignOutAndAttemptNewSignIn: Bool = response.authMethod == .renewedAccessToken && numberOfSignInRetries < 1
                
                guard !shouldSignOutAndAttemptNewSignIn else {
                    
                    numberOfSignInRetries += 1
                    
                    self?.removeSecureStorageAndRevokeStateManager(completion: { [weak self] (revokeResponse: OktaRevokeResponse) in
                        
                        self?.renewAccessTokenElseAuthenticate(fromViewController: fromViewController, completion: completion)
                    })
                    
                    return
                }
            }
            
            completion(response)
        }        
    }
    
    public func signOut(fromViewController: UIViewController, completion: @escaping ((_ signOutResponse: OktaSignOutResponse) -> Void)) {
        
        super.signOut(fromViewController: fromViewController, forceRemoveSecureStorageAndRevokeStateManager: true, completion: completion)
    }
    
    public func getAuthorizedCruUser(completion: @escaping ((_ result: Result<CruOktaUser, OktaAuthenticationError>) -> Void)) {
        getAuthorizedCodableUser { (_ result: Result<CruOktaUser, OktaAuthenticationError>) in
            completion(result)
        }
    }
}
