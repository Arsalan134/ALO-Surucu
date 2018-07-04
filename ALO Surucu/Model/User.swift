//
//  User.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 21.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import Foundation

var statusGLOBAL: Status = .offline

struct User: Codable {
    var url: String?
    var name: String?
    var surname: String?
    var status: String?
    var isBlocked: Bool?
    var balance: String?
    var transferAccess: Bool?
    var username: String?
    
//    private enum CodingKeys: String, CodingKey {
//        case id = "table_id", firstname = "name", lastname = "surname", balance, status, phone, balansKocurme = "bk", isBlocked = "block", username, index
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = try values.decode(String.self, forKey: .id)
//        firstname = try values.decode(String.self, forKey: .firstname)
//        lastname = try values.decode(String.self, forKey: .lastname)
//        balance = try values.decode(Double.self, forKey: .balance)
//        status = try values.decode(String.self, forKey: .status)
//        username = try values.decode(String.self, forKey: .username)
//        phone = try values.decode(String.self, forKey: .phone)
//        balansKocurme = try values.decode(Bool.self, forKey: .balansKocurme)
//        isBlocked = try values.decode(Bool.self, forKey: .isBlocked)
//        index = try values.decode(Int.self, forKey: .index)
////        limit = try values.decode(Double?.self, forKey: .limit)
//    }

}

enum StatusOfDriver: String {
    case none, catmisam, yoldayam, gozleyirem
}


