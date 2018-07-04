//
//  NoInternetViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 05.06.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit

class NoInternetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)
        reachabilityChanged()
    }

    @objc func reachabilityChanged() {
        print("State:", socket.readyState)
        switch socket.readyState {
        case .open:
            self.dismiss(animated: true)
        default: break
        }
    }

}




