//
//  CruOktaAuthentication+Combine.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 09/27/22.
//  Copyright © 2022 Cru Global, Inc. All rights reserved.
//

import UIKit
import Combine

extension CruOktaAuthentication {
    
    public func signInPublisher(fromViewController: UIViewController) -> AnyPublisher<OktaAuthenticationResponse, Never> {
        
        return Future() { promise in
            
            self.signIn(fromViewController: fromViewController) { (response: OktaAuthenticationResponse) in
                
                promise(.success(response))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func signOutPublisher(fromViewController: UIViewController) -> AnyPublisher<OktaSignOutResponse, Never> {
        
        return Future() { promise in
            
            self.signOut(fromViewController: fromViewController) { (signOutResponse: OktaSignOutResponse) in
                
                promise(.success(signOutResponse))
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func getAuthorizedCruUserPublisher() -> AnyPublisher<CruOktaUser, OktaAuthenticationError> {
        
        return Future() { promise in
            
            self.getAuthorizedCodableUser { (result: Result<CruOktaUser, OktaAuthenticationError>) in
                
                switch result {
                    
                case .success(let cruOktaUser):
                    promise(.success(cruOktaUser))
                    
                case .failure(let oktaAuthenticationError):
                    promise(.failure(oktaAuthenticationError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
