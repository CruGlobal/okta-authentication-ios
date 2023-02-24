//
//  OktaAuthenticationPolicy.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 2/24/23.
//  Copyright © 2023 Cru Global, Inc. All rights reserved.
//

import Foundation

public enum OktaAuthenticationPolicy {
    
    case attemptToRenewAccessTokenElseSignInWithBrowser(shouldSignOutAndRetryAuthenticationIfAuthenticationFails: Bool)
    case signInWithBrowser
}
