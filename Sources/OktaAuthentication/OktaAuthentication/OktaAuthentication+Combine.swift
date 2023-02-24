//
//  OktaAuthentication+Combine.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 09/27/22.
//  Copyright © 2022 Cru Global, Inc. All rights reserved.
//

import UIKit
import Combine

extension OktaAuthentication {
    
    public func authenticatePublisher(fromViewController: UIViewController, policy: OktaAuthenticationPolicy) -> AnyPublisher<OktaAuthenticationResponse, Never> {
        
        return Future() { promise in
                
            self.authenticate(fromViewController: fromViewController, policy: policy) { (response: OktaAuthenticationResponse) in
                
                promise(.success(response))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func renewAccessTokenPublisher() -> AnyPublisher<OktaAuthenticationResponse, Never> {
        
        return Future() { promise in
            
            self.renewAccessToken { (response: OktaAuthenticationResponse) in
                
                promise(.success(response))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func signOutPublisher(fromViewController: UIViewController, forceRemoveSecureStorageAndRevokeStateManager: Bool = false) -> AnyPublisher<OktaSignOutResponse, Never> {
        
        return Future() { promise in
            
            self.signOut(fromViewController: fromViewController, forceRemoveSecureStorageAndRevokeStateManager: forceRemoveSecureStorageAndRevokeStateManager) { (signOutResponse: OktaSignOutResponse) in
                
                promise(.success(signOutResponse))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func removeSecureStorageAndRevokeStateManagerPublisher() -> AnyPublisher<OktaRevokeResponse, Never> {
        
        return Future() { promise in
            
            self.removeSecureStorageAndRevokeStateManager { (revokeResponse: OktaRevokeResponse) in
                
                promise(.success(revokeResponse))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func getAuthorizedCodableUserPublisher<CodableUser: Codable>() -> AnyPublisher<CodableUser, OktaAuthenticationError> {
        
        return Future() { promise in
            
            self.getAuthorizedCodableUser { (result: Result<CodableUser, OktaAuthenticationError>) in
                
                switch result {
                    
                case .success(let codableUser):
                    promise(.success(codableUser))
                    
                case .failure(let oktaAuthenticationError):
                    promise(.failure(oktaAuthenticationError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func getAuthorizedUserJsonObjectPublisher() -> AnyPublisher<[String: Any], OktaAuthenticationError> {
        
        return Future() { promise in
            
            self.getAuthorizedUserJsonObject { (result: Result<[String: Any], OktaAuthenticationError>) in
                
                switch result {
                    
                case .success(let userObject):
                    promise(.success(userObject))
                    
                case .failure(let oktaAuthenticationError):
                    promise(.failure(oktaAuthenticationError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
