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
    
    public required init(clientId: String, logoutRedirectUri: String, issuer: String, redirectUri: String) {
        
        super.init(configModel: OktaConfigModel(
            clientId: clientId,
            logoutRedirectUri: logoutRedirectUri,
            issuer: issuer,
            prompt: CruOktaAuthentication.defaultPrompt,
            redirectUri: redirectUri,
            scopes: CruOktaAuthentication.defaultScopes)
        )
    }
    
    public required init(configModel: OktaConfigModelType) {
        fatalError("init(configModel:) is not supported.")
    }
    
    public func signIn(fromViewController: UIViewController, completion: @escaping ((_ result: Result<OktaAccessToken, OktaAuthenticationError>, _ authMethodType: OktaAuthMethodType) -> Void)) {
        
        var numberOfSignInRetries: Int = 0
        
        super.renewAccessTokenElseAuthenticate(fromViewController: fromViewController) { [weak self] (result: Result<OktaAccessToken, OktaAuthenticationError>, authMethodType: OktaAuthMethodType) in
            
            switch result {
           
            case .success( _):
                break
            
            case .failure( _):
                
                let shouldSignOutAndAttemptNewSignIn: Bool = authMethodType == .renewedAccessToken && numberOfSignInRetries < 1
                
                guard !shouldSignOutAndAttemptNewSignIn else {
                    
                    numberOfSignInRetries += 1
                    
                    self?.removeSecureStorageAndRevokeStateManager(completion: { [weak self] (removeFromSecureStorageError: Error?, revokeError: Error?) in
                        
                        self?.renewAccessTokenElseAuthenticate(fromViewController: fromViewController, completion: completion)
                    })
                    
                    return
                }
            }
            
            
            completion(result, authMethodType)
        }
        
        super.renewAccessTokenElseAuthenticate(fromViewController: fromViewController, completion: completion)
    }
    
    public func signOut(fromViewController: UIViewController, completion: @escaping ((_ signOutError: OktaAuthenticationError?, _ removeFromSecureStorageError: Error?, _ revokeError: Error?) -> Void)) {
        
        super.signOut(fromViewController: fromViewController, forceRemoveSecureStorageAndRevokeStateManager: true, completion: completion)
    }
    
    public func getAuthorizedCruUser(completion: @escaping ((_ result: Result<CruOktaUser, OktaAuthenticationError>) -> Void)) {
        getAuthorizedCodableUser { (_ result: Result<CruOktaUser, OktaAuthenticationError>) in
            completion(result)
        }
    }
}
