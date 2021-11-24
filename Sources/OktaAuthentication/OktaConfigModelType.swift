//
//  OktaConfigModelType.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation
import OktaOidc

public protocol OktaConfigModelType {
        
    func getEncodedData() -> [String: String]
}
