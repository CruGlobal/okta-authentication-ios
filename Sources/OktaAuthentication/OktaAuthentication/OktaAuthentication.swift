//
//  OktaAuthentication.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import UIKit
import OktaOidc

public class OktaAuthentication {
    
    private static var sharedStateManager: OktaOidcStateManager?
    private static var sharedInMemoryAccessToken: String?
    
    private let oktaOidc: OktaOidc?
            
    public required init(configModel: OktaConfigModelType) {
        
        let configData: [String: String] = configModel.getEncodedData()
        
        do {
            let oktaOidcConfig: OktaOidcConfig = try OktaOidcConfig(with: configData)
            oktaOidc = try OktaOidc(configuration: oktaOidcConfig)
            OktaAuthentication.sharedStateManager = OktaOidcStateManager.readFromSecureStorage(for: oktaOidcConfig)
        }
        catch let error {
            assertionFailure("Failed to initialize OktaOidc with error: \(error)")
            oktaOidc = nil
        }
    }
    
    public var refreshTokenExists: Bool {
        return OktaAuthentication.sharedStateManager?.refreshToken != nil
    }
    
    public func getAccessTokenFromPersistentStore() -> String? {
        return OktaAuthentication.sharedInMemoryAccessToken ?? OktaAuthentication.sharedStateManager?.accessToken
    }
    
    public func renewAccessTokenElseAuthenticate(fromViewController: UIViewController, completion: @escaping ((_ result: Result<OktaAccessToken, OktaAuthenticationError>, _ authMethodType: OktaAuthMethodType) -> Void)) {
        
        if refreshTokenExists {
            
            renewAccessToken { result in
                completion(result, .renewedAccessToken)
            }
        }
        else {
            
            authenticate(fromViewController: fromViewController) { result in
                completion(result, .newAuthorization)
            }
        }
    }
    
    public func authenticate(fromViewController: UIViewController, completion: @escaping ((_ result: Result<OktaAccessToken, OktaAuthenticationError>) -> Void)) {
        
        guard let oktaOidc = self.oktaOidc else {
            completion(.failure(.internalError(error: nil, message: "Failed to authenticate, found null OktaOidc.")))
            return
        }
        
        oktaOidc.signInWithBrowser(from: fromViewController, callback: { (manager: OktaOidcStateManager?, error: Error?) in
            
            if let manager = manager,
               let accessToken = manager.accessToken {
                
                OktaAuthentication.sharedStateManager = manager
                OktaAuthentication.sharedInMemoryAccessToken = accessToken
                
                manager.writeToSecureStorage()
                                
                completion(.success(OktaAccessToken(value: accessToken)))
            }
            else if let error = error {
                    
                completion(.failure(.oktaSdkError(error: error)))
            }
            else {
                               
                completion(.failure(.internalError(error: nil, message: "Okta authentication failed with unknown reason.")))
            }
        })
    }
    
    public func renewAccessToken(completion: @escaping ((_ result: Result<OktaAccessToken, OktaAuthenticationError>) -> Void)) {
        
        guard let sharedStateManager = OktaAuthentication.sharedStateManager else {
            completion(.failure(.internalError(error: nil, message: "Okta refreshAccessToken failed, found null OktaOidcStateManager.")))
            return
        }
        
        sharedStateManager.renew(callback: { (newStateManager: OktaOidcStateManager?, error: Error?) in
            
            if let error = error {
                
                completion(.failure(.oktaSdkError(error: error)))
            }
            else if let stateManager = newStateManager, let accessToken = stateManager.accessToken {
                
                OktaAuthentication.sharedStateManager = newStateManager
                OktaAuthentication.sharedInMemoryAccessToken = accessToken
                
                completion(.success(OktaAccessToken(value: accessToken)))
            }
            else {
                
                completion(.failure(.internalError(error: nil, message: "Okta refreshAccessToken failed with unknown reason.")))
            }
        })
    }
    
    public func signOut(fromViewController: UIViewController, forceRemoveSecureStorageAndRevokeStateManager: Bool = false, completion: @escaping ((_ signOutError: OktaAuthenticationError?, _ removeFromSecureStorageError: Error?, _ revokeError: Error?) -> Void)) {
                
        guard let oktaOidc = self.oktaOidc, let sharedStateManager = OktaAuthentication.sharedStateManager else {
            completion(.internalError(error: nil, message: "Okta signOut failed, found null OktaOidcStateManager."), nil, nil)
            return
        }
                
        oktaOidc.signOutOfOkta(sharedStateManager, from: fromViewController) { [weak self] (error: Error?) in
            
            if let error = error {
                
                if forceRemoveSecureStorageAndRevokeStateManager {
                    
                    self?.removeSecureStorageAndRevokeStateManager { (removeFromSecureStorageError: Error?, revokeError: Error?) in
                        
                        completion(nil, removeFromSecureStorageError, revokeError)
                    }
                }
                else {
                    
                    completion(.oktaSdkError(error: error), nil, nil)
                }
            }
            else {
                
                self?.removeSecureStorageAndRevokeStateManager { (removeFromSecureStorageError: Error?, revokeError: Error?) in
                    
                    completion(nil, removeFromSecureStorageError, revokeError)
                }
            }
        }
    }
    
    public func removeSecureStorageAndRevokeStateManager(completion: @escaping ((_ removeFromSecureStorageError: Error?, _ revokeError: Error?) -> Void)) {
        
        guard let sharedStateManager = OktaAuthentication.sharedStateManager else {
            let error: OktaAuthenticationError = .internalError(error: nil, message: "Okta removeSecureStorage failed, found null OktaOidcStateManager.")
            completion(error, nil)
            return
        }
        
        var removeFromSecureStorageError: Error?
        var revokeError: Error?
        
        OktaAuthentication.sharedStateManager = nil
        OktaAuthentication.sharedInMemoryAccessToken = nil
        
        do {
            try sharedStateManager.removeFromSecureStorage()
        }
        catch let error {
            removeFromSecureStorageError = error
        }
        
        sharedStateManager.revoke(sharedStateManager.refreshToken) { (response: Bool, error: Error?) in
            
            revokeError = error
            completion(removeFromSecureStorageError, revokeError)
        }

    }
}

// MARK: - Authorized User

extension OktaAuthentication {
    
    public func getAuthorizedCodableUser<CodableUser: Codable>(completion: @escaping ((_ result: Result<CodableUser, OktaAuthenticationError>) -> Void)) {
        
        getAuthorizedUserJsonObject { (_ result: Result<[String: Any], OktaAuthenticationError>) in
            
            switch result {
                
            case .success(let userJsonObject):
                
                guard !userJsonObject.isEmpty && JSONSerialization.isValidJSONObject(userJsonObject) else {
                    completion(.failure(.internalError(error: nil, message: "Failed to decode user data.  Data is either empty or invalid.")))
                    return
                }
                
                do {
                    
                    let userData: Data = try JSONSerialization.data(withJSONObject: userJsonObject, options: [])
                    let codableUser: CodableUser = try JSONDecoder().decode(CodableUser.self, from: userData)
                    
                    completion(.success(codableUser))
                }
                catch let error {
                    
                    completion(.failure(.internalError(error: error, message: "Failed to decode user data, failed with error: \(error.localizedDescription)")))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getAuthorizedUserJsonObject(completion: @escaping ((_ result: Result<[String: Any], OktaAuthenticationError>) -> Void)) {
        
        guard let sharedStateManager = OktaAuthentication.sharedStateManager else {
            completion(.failure(.internalError(error: nil, message: "Failed to get authorized user, found null OktaOidcStateManager.")))
            assertionFailure("Okta manager should be available.  Okta either is not configured properly or a user is not authorized.")
            return
        }
        
        sharedStateManager.getUser({ (userData: [String : Any]?, error: Error?) in
            
            if let error = error {
                
                completion(.failure(.oktaSdkError(error: error)))
            }
            else if let userData = userData {
                                                
                completion(.success(userData))
            }
            else {
                completion(.failure(.internalError(error: nil, message: "Okta authentication failed with no user or error reported.")))
            }
        })
    }
}
