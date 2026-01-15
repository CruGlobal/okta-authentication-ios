//
//  OktaAuthMethodType.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 12/22/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation

public enum OktaAuthMethodType: Sendable {
    
    case newAuthorization
    case renewedAccessToken
}
