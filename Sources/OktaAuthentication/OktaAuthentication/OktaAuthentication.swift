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
}

// MARK: - Authentication

extension OktaAuthentication {
    
    public var refreshTokenExists: Bool {
        return OktaAuthentication.sharedStateManager?.refreshToken != nil
    }
    
    public func getAccessTokenFromPersistentStore() -> String? {
        return OktaAuthentication.sharedInMemoryAccessToken ?? OktaAuthentication.sharedStateManager?.accessToken
    }
    
    public func renewAccessTokenElseAuthenticate(fromViewController: UIViewController, completion: @escaping ((_ response: OktaAuthenticationResponse) -> Void)) {
        
        if refreshTokenExists {
            renewAccessToken(completion: completion)
        }
        else {
            authenticate(fromViewController: fromViewController, completion: completion)
        }
    }
    
    public func authenticate(fromViewController: UIViewController, completion: @escaping ((_ response: OktaAuthenticationResponse) -> Void)) {
        
        let authMethod: OktaAuthMethodType = .newAuthorization
        
        guard let oktaOidc = self.oktaOidc else {
            
            let response = OktaAuthenticationResponse(
                result: .failure(.internalError(error: nil, message: "Failed to authenticate, found null OktaOidc.")),
                authMethod: authMethod
            )
            
            completion(response)
            
            return
        }
        
        oktaOidc.signInWithBrowser(from: fromViewController, callback: { (manager: OktaOidcStateManager?, error: Error?) in
            
            let result: Result<OktaAccessToken, OktaAuthenticationError>
            
            if let manager = manager, let accessToken = manager.accessToken {
                
                OktaAuthentication.sharedStateManager = manager
                OktaAuthentication.sharedInMemoryAccessToken = accessToken
                
                manager.writeToSecureStorage()
                                
                result = .success(OktaAccessToken(value: accessToken))
            }
            else if let error = error {
                    
                result = .failure(.oktaSdkError(error: error))
            }
            else {
                               
                result = .failure(.internalError(error: nil, message: "Okta authentication failed with unknown reason."))
            }
            
            let response = OktaAuthenticationResponse(
                result: result,
                authMethod: authMethod
            )
            
            completion(response)
        })
    }
    
    public func renewAccessToken(completion: @escaping ((_ response: OktaAuthenticationResponse) -> Void)) {
        
        let authMethod: OktaAuthMethodType = .renewedAccessToken
        
        guard let sharedStateManager = OktaAuthentication.sharedStateManager else {
            
            let response = OktaAuthenticationResponse(
                result: .failure(.internalError(error: nil, message: "Okta refreshAccessToken failed, found null OktaOidcStateManager.")),
                authMethod: authMethod
            )
            
            completion(response)
            
            return
        }
        
        sharedStateManager.renew(callback: { (newStateManager: OktaOidcStateManager?, error: Error?) in
            
            let result: Result<OktaAccessToken, OktaAuthenticationError>
            
            if let error = error {
                
                result = .failure(.oktaSdkError(error: error))
            }
            else if let stateManager = newStateManager, let accessToken = stateManager.accessToken {
                
                OktaAuthentication.sharedStateManager = newStateManager
                OktaAuthentication.sharedInMemoryAccessToken = accessToken
                
                result = .success(OktaAccessToken(value: accessToken))
            }
            else {
                
                result = .failure(.internalError(error: nil, message: "Okta refreshAccessToken failed with unknown reason."))
            }
            
            let response = OktaAuthenticationResponse(
                result: result,
                authMethod: authMethod
            )
            
            completion(response)
        })
    }
}

// MARK: - Sign Out

extension OktaAuthentication {
    
    public func signOut(fromViewController: UIViewController, forceRemoveSecureStorageAndRevokeStateManager: Bool = false, completion: @escaping ((_ signOutResponse: OktaSignOutResponse) -> Void)) {
                
        guard let oktaOidc = self.oktaOidc, let sharedStateManager = OktaAuthentication.sharedStateManager else {
            
            let oktaAuthenticationError: OktaAuthenticationError = .internalError(error: nil, message: "Okta signOut failed, found null OktaOidcStateManager.")
            
            let signOutResponse = OktaSignOutResponse(signOutError: oktaAuthenticationError, revokeResponse: nil)
            
            completion(signOutResponse)
            
            return
        }
                
        oktaOidc.signOutOfOkta(sharedStateManager, from: fromViewController) { [weak self] (error: Error?) in
            
            if let error = error {
                
                if forceRemoveSecureStorageAndRevokeStateManager {
                    
                    self?.removeSecureStorageAndRevokeStateManager { (revokeResponse: OktaRevokeResponse) in
                        
                        let signOutResponse = OktaSignOutResponse(signOutError: nil, revokeResponse: revokeResponse)
                        
                        completion(signOutResponse)
                    }
                }
                else {
                    
                    let signOutResponse = OktaSignOutResponse(signOutError: .oktaSdkError(error: error), revokeResponse: nil)
                    
                    completion(signOutResponse)
                }
            }
            else {
                
                self?.removeSecureStorageAndRevokeStateManager { (revokeResponse: OktaRevokeResponse) in
                    
                    let signOutResponse = OktaSignOutResponse(signOutError: nil, revokeResponse: revokeResponse)
                    
                    completion(signOutResponse)
                }
            }
        }
    }
    
    public func removeSecureStorageAndRevokeStateManager(completion: @escaping ((_ revokeResponse: OktaRevokeResponse) -> Void)) {
        
        guard let sharedStateManager = OktaAuthentication.sharedStateManager else {
            
            let error: OktaAuthenticationError = .internalError(error: nil, message: "Okta removeSecureStorage failed, found null OktaOidcStateManager.")
            
            let revokeResponse = OktaRevokeResponse(removeFromSecureStorageError: error, revokeError: nil)
            
            completion(revokeResponse)
            
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
            
            let revokeResponse = OktaRevokeResponse(removeFromSecureStorageError: removeFromSecureStorageError, revokeError: revokeError)
            
            completion(revokeResponse)
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
