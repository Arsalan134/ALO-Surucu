//
//  Responses.swift
//  Alamofire
//
//  Created by Arsalan Iravani on 31.05.2018.
//

import Foundation
import SwiftyJSON

struct Response: Codable {
    var url: String?
    var index: Int?
    var state: Bool?
    var iosVersionNumber: Double?
    var reason: String?
    var token: String?
    var username: String?
    var title: String?
    var body: String?
    var id: String?
    var price: String?
}

struct MessagesListResponse: Codable {
    var url: String?
    var data: [Message]?
}

struct Message: Codable {
    var _id: String?
    var to: String?
    var message: String?
    var timestamp: String?
}

struct OrdersListResponse: Codable {
    var url: String?
    var orders: [Order]?
}

struct TokenResponse: Codable {
    var username: String?
    var name: String?
    var surname: String?
    var balance: String?
    var isBlock: Bool?
    var status: String?
    var limit: String?
    var state: Bool?
}

struct Order: Codable {
    var url: String?
    var id: String?
    var clientNumber: String?
    var from: String?
    var to: String?
    var time: String?
    var timestamp: String?
    var price: String?
    var cerime: Double?
    var carNumber: String?
    var details: String?
    var isPlanned: Bool?
    var coordinator: String?
}












