//
//  Extension.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 29.05.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(bytes: jsonData, encoding: .utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }

    func toJson() -> String {
        return json
    }
}

extension String {
    func convert2Dictionary() -> Dictionary<String, Any>? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any>
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}






