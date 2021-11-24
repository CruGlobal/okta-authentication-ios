//
//  MinimumOktaConfigAttributes.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation

public protocol MinimumOktaConfigAttributes {
    
    var clientId: String { get }
    var logoutRedirectUri: String { get }
    var issuer: String { get }
    var redirectUri: String { get }
    var scopes: String { get }
}

extension MinimumOktaConfigAttributes {
    
    func getMinimumOktaConfigEncodedData() -> [String: String] {
        
        let data: [String: String] = [
            "issuer": issuer,
            "clientId": clientId,
            "logoutRedirectUri": logoutRedirectUri,
            "redirectUri": redirectUri,
            "scopes": scopes
        ]
        
        return data
    }
}
