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
