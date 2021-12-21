//
//  OktaConfigModel.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation

public struct OktaConfigModel: OktaConfigModelType {
    
    public let clientId: String
    public let logoutRedirectUri: String
    public let issuer: String
    public let prompt: String?
    public let redirectUri: String
    public let scopes: String
}
