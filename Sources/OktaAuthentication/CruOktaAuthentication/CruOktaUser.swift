//
//  CruOktaUser.swift
//  OktaAuthentication
//
//  Created by Levi Eggert on 11/24/21.
//  Copyright © 2021 Cru Global, Inc. All rights reserved.
//

import Foundation

public struct CruOktaUser: Codable, Sendable {
    
    public let email: String
    public let grMasterPersonId: String
    public let name: String
    public let ssoguid: String
    
    enum CodingKeys: String, CodingKey {
        
        case email = "email"
        case grMasterPersonId = "grMasterPersonId"
        case name = "name"
        case ssoguid = "ssoguid"
    }
}
