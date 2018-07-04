//
//  SocketCommunication.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 29.05.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftWebSocket
//import Alamofire

let socket = WebSocket(websocket)
let router = Router()

class Socket: WebSocketDelegate {

    private var timer: Timer?

    @objc func connect() {
        print("\nTrying to connect to:", websocket)
        socket.delegate = self
        socket.services = [.Background]
        socket.open()

        if socket.readyState == .open {
            timer?.invalidate()
            guard let username = currentUser()?.username else {return}
            let request = ["url":"drivers/registerSocket", "username": username]
            socket.send(request.toJson())
        }
    }

    func webSocketOpen() {
        print("\nDid open")
        timer?.invalidate()
        NotificationCenter.default.post(name: .socketConnectionChanged, object: nil)
    }

    @objc func reconnect() {
        if socket.readyState != .open {
            print("\nReconnectiong to:", websocket)
            connect()
        } else {
            timer?.invalidate()
        }
        NotificationCenter.default.post(name: .socketConnectionChanged, object: nil)
    }

    func webSocketClose(_ code: Int, reason: String, wasClean: Bool){
        print("\nDid close with code:", code, ".Reason:", reason, ".Cleaned:", wasClean, "\n")
        NotificationCenter.default.post(name: .socketConnectionChanged, object: nil)
        reconnect()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(reconnect), userInfo: nil, repeats: true)
    }

    func webSocketError(_ error: NSError) {
        print("\nSocket Error:", error)
        socket.close()
        NotificationCenter.default.post(name: .socketConnectionChanged, object: nil)
    }

    func webSocketMessageText(_ text: String) {
        print("\nRecieved text:", text, "\n")
        router.recieved(text)
    }

}
