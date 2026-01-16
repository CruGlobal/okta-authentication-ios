//
//  OktaSignOutResponse.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 09/27/22.
//  Copyright © 2022 Cru Global, Inc. All rights reserved.
//

import Foundation

public struct OktaSignOutResponse: Sendable {
    
    public let signOutError: OktaAuthenticationError?
    public let revokeResponse: OktaRevokeResponse?
}

