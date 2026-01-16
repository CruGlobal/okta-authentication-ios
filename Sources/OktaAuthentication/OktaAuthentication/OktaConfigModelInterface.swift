//
//  OktaConfigModelInterface.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation
import OktaOidc

public protocol OktaConfigModelInterface: Sendable {
        
    var clientId: String { get }
    var logoutRedirectUri: String { get }
    var issuer: String { get }
    var prompt: String? { get }
    var redirectUri: String { get }
    var scopes: String { get }
    
    func getEncodedData() -> [String: String]
}

extension OktaConfigModelInterface {
    
    public func getEncodedData() -> [String: String] {
        
        var data: [String: String] = [
            "issuer": issuer,
            "clientId": clientId,
            "logoutRedirectUri": logoutRedirectUri,
            "redirectUri": redirectUri,
            "scopes": scopes
        ]
        
        if let prompt = prompt {
            data["prompt"] = prompt
        }
        
        return data
    }
}
