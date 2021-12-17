//
//  AuthenticationView.swift
//  Example
//
//  Created by Levi Eggert on 9/13/21.
//

import UIKit
import OktaAuthentication

class AuthenticationView: UIViewController {
    
    private let authentication: OktaAuthentication
    
    private var firstViewAppear: Bool = true
    
    required init() {
        
        // TODO: Need to setup an Okta clientId for working with the example project. ~Levi
        
        authentication = OktaAuthentication(configModel: ProvidedOktaConfigModel(
            clientId: "",
            logoutRedirectUri: "",
            issuer: "",
            redirectUri: "",
            scopes: "openid profile offline_access email",
            prompt: nil,
        ))
        
        super.init(nibName: String(describing: AuthenticationView.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard firstViewAppear else {
            return
        }
        firstViewAppear = false
        
        authentication.authenticate(fromViewController: self) { (result: Result<OktaAccessToken, OktaAuthenticationError>) in
            
            print("auth completed...")
        }
    }
}
