//
//  OktaAuthenticationError.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation

public enum OktaAuthenticationError: Error {
    
    case internalError(error: Error?, message: String)
    case oktaSdkError(error: Error)
    
    public var errorCode: Int {
        switch self {
        case .internalError(let error, _):
            if let error = error {
                return (error as NSError).code
            }
            return -1
        case .oktaSdkError(let error):
            return (error as NSError).code
        }
    }
}
