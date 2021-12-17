//
//  ProvidedOktaConfigModel.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation

public struct ProvidedOktaConfigModel: OktaConfigModelType, MinimumOktaConfigAttributes {
    
    public let clientId: String
    public let logoutRedirectUri: String
    public let issuer: String
    public let redirectUri: String
    public let scopes: String
    public let prompt: String
    
    public init(clientId: String, logoutRedirectUri: String, issuer: String, redirectUri: String, scopes: String) {
        
        self.clientId = clientId
        self.logoutRedirectUri = logoutRedirectUri
        self.issuer = issuer
        self.redirectUri = redirectUri
        self.scopes = scopes
        self.prompt = "login"
    }

    public init(clientId: String, logoutRedirectUri: String, issuer: String, redirectUri: String, scopes: String, prompt: String) {
        
        self.clientId = clientId
        self.logoutRedirectUri = logoutRedirectUri
        self.issuer = issuer
        self.redirectUri = redirectUri
        self.scopes = scopes
        self.prompt = prompt
    }
    
    public func getEncodedData() -> [String : String] {
        
        return getMinimumOktaConfigEncodedData()
    }
}
