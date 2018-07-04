//
//  Functions.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 27.05.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import Foundation
import SwiftyJSON
//import SystemConfiguration
import UserNotifications
import UIKit

func currentUser() -> User? {
    guard
        let data = UserDefaults.standard.data(forKey: userKeyString),
        let user: User = try? PropertyListDecoder().decode(User.self, from: data)
        else {return nil}
    return user
}

enum Status: String {
    case online = "online", offline = "offline", inservice = "inservice"
}

enum ErrorType {
    case noGPS, newUpdateAvailable, none
}

func returnStatus(_ string: String) -> Status {
    switch string {
    case "online":
        return .online
    case "offline":
        return .offline
    case "inservice":
        return .inservice
    default:
        return .online
    }
}

/// Removes order from UserDefaults
func clearOrderDefaults() {
    UserDefaults.standard.removeObject(forKey: orderKeyString)
    print("\nRemoved order from User Defaults")
}

/// Saves order to User Defaults
///
/// - Parameter order: Order object
func saveToUserDefaults(_ order: Order?) {
    guard order != nil else {
        print("Unable to save order to UserDefaults, Order is nil")
        return
    }
    UserDefaults.standard.set(try? PropertyListEncoder().encode(order), forKey: orderKeyString)
    print("\nOrder saved to User Defaults")
}

/// Saves user to User Defaults
///
/// - Parameter user: user object
func saveToUserDefaults(_ user: User) {
    UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: userKeyString)
    print("\nUser saved to User Defaults")
}

func removeUserFromUserDefaults() {
    UserDefaults.standard.removeObject(forKey: userKeyString)
    print("\nUser removed from User Defaults")
}

/// Saves statusOfDriver to User Defaults
///
/// - Parameter statusOfDriver: statusOfDriver object
func saveToUserDefaults(_ statusOfDriver: StatusOfDriver) {
    UserDefaults.standard.set(statusOfDriver.rawValue, forKey: statusOfDriverKeyString)
    print("\nStatusOfDriver saved to User Defaults")
}

func clearDriverStatusFromUserDefaults() {
    UserDefaults.standard.removeObject(forKey: statusOfDriverKeyString)
    print("\nStatusOfDriver removed from User Defaults")
}

func savedStatus() -> StatusOfDriver? {
    guard let statusString: String = UserDefaults.standard.value(forKey: statusOfDriverKeyString) as? String else {return nil}
    let status: StatusOfDriver? = StatusOfDriver(rawValue: statusString)
    return status
}

func downloadMessages() {
    guard let user = currentUser(), let token = currentToken() else {return}
    let request = ["url":"broadcast/listDriver", "username": user.username, "token": token]
    socket.send(request.toJson())
}

func saveTime(_ date: Date) {
    UserDefaults.standard.set(date, forKey: startTimeKeyString)
    print("\nSaved")
}

func loadTime() -> Date? {
    let date = UserDefaults.standard.object(forKey: startTimeKeyString) as? Date
    print("\nLoaded")
    return date
}

func removeTime() {
    UserDefaults.standard.removeObject(forKey: startTimeKeyString)
    print("\nRemoved")
}

func clearUserDefaults() {
    UserDefaults.standard.removeObject(forKey: orderKeyString)
    UserDefaults.standard.removeObject(forKey: pageKeyString)
    UserDefaults.standard.removeObject(forKey: userKeyString)
    UserDefaults.standard.removeObject(forKey: tokenKeyString)
}

enum SavedPage: String, Codable {
    case catdim = "catdim", newOrder = "newOrder", bitdi = "bitdi", tamamla = "tamamla"
}

/// Saves page to User Defaults
///
/// - Parameter page: page object
func saveToUserDefaults(_ page: SavedPage) {
    UserDefaults.standard.set(page.rawValue, forKey: pageKeyString)
    print("\nPage saved to User Defaults")
}

func savedPage() -> SavedPage? {
    guard let pageString: String = UserDefaults.standard.value(forKey: pageKeyString) as? String else {return nil}
    let page: SavedPage? = SavedPage(rawValue: pageString)
    return page
}

func orderFromUserDefaults() -> Order? {
    print("\nTrying to load order from User Defaults")
    guard
        let data = UserDefaults.standard.data(forKey: orderKeyString),
        let order: Order = try? PropertyListDecoder().decode(Order.self, from: data)
        else {return nil}
    return order
}

func allowedToDownload() -> Bool {
    return !(currentUser()?.isBlocked ?? false) && statusGLOBAL != .offline
}

func convertToPrice(price: Double, fontSize: CGFloat? = 18) -> NSAttributedString {

    let combination = NSMutableAttributedString()

    if let f = UIFont(name: "JIS AZN", size: fontSize!) {
        let price =  String(format: "%.2f ", price)
        let yourOtherAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: f]
        let partZero = NSMutableAttributedString(string: "Balans: ", attributes: yourOtherAttributes)
        let partOne = NSMutableAttributedString(string: price, attributes: yourOtherAttributes)
        let partTwo = NSMutableAttributedString(string: "M", attributes: yourOtherAttributes)
        combination.append(partZero)
        combination.append(partOne)
        combination.append(partTwo)
    }
    return combination
}

@available(iOS 10.0, *)
func createNotification(title: String?, body: String?) {
    let content = UNMutableNotificationContent()
    content.title = title ?? ""
    content.body = body ?? ""
    content.sound = UNNotificationSound.default()
    let request = UNNotificationRequest(identifier: "test", content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
}

func currentToken() -> String? {
    guard let token = UserDefaults.standard.value(forKey: tokenKeyString) as? String else {return nil}
    return token
}

func downloadUser() {
    guard let user = currentUser(), let token = currentToken() else {return}
    let request = ["url":"drivers/info", "username": user.username, "token": token]
    socket.send(request.toJson())
}

func downloadOrders() {
    if allowedToDownload() {
        guard let token = currentToken() else {return}
        let request = ["url": "orders/listDriver", "username": currentUser()?.username ?? "no username", "token": token]
        socket.send(request.toJson())
    }
}
