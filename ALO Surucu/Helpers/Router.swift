//
//  Router.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 30.05.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class Router {
    
    func recieved(_ message: String) {
        
        let data = message.data(using: .utf8)!
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(Response.self, from: data)
            
            switch response.url {
            case "orders/new":
                if #available(iOS 10.0, *) {
                    UIDevice.vibrate()
                    createNotification(title: response.title, body: response.body)
                } else {
                    // Fallback on earlier versions
                }

            case "broadcast/new":
                if #available(iOS 10.0, *) {
                    UIDevice.vibrate()
                    createNotification(title: response.title, body: response.body)
                } else {
                    // Fallback on earlier versions
                }
                downloadMessages()
                
            case "drivers/info":
                let user = try decoder.decode(User.self, from: data)
                statusGLOBAL = returnStatus(user.status ?? "online")
                if response.state == false {
                    removeUserFromUserDefaults()
                    clearUserDefaults()
                } else {
                    saveToUserDefaults(user)
                }
                NotificationCenter.default.post(name: .refresh, object: nil)
                
            case "ping":
                let request: [String: Any] = ["url": "pong", "index": response.index ?? -1]
                socket.send(request.toJson())
                
            default:
                break
            }
        } catch {}
    }
}
