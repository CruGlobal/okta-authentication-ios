//
//  OktaAuthenticationResponse.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 09/27/22.
//  Copyright © 2022 Cru Global, Inc. All rights reserved.
//

import Foundation

public struct OktaAuthenticationResponse: Sendable {
    
    public let result: Result<OktaAccessToken, OktaAuthenticationError>
    public let authMethod: OktaAuthMethodType
}
