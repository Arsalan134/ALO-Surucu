//
//  ErrorViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 07.06.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit
import CoreLocation

class ErrorViewController: UIViewController {

    var message: String?
    var animate: Bool?
    private let locationManager = CLLocationManager()

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message ?? "asdasd"
        (animate ?? false) ? activityIndicator.startAnimating() : print()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
    }
}

extension ErrorViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("2 Location status is OK.")
//            socketObject.reconnect()
            self.dismiss(animated: true)
        default: break
        }
    }
}
