//
//  RootViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 30.05.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit
import CoreLocation

var errorGlobal: ErrorType?

class RootViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!

    var locationManager = CLLocationManager()
    var bool = false
    func createLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = 200
    }

    @objc func asb() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "login") {
            DispatchQueue.main.async {
                self.present(vc, animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        clearUserDefaults()
        createLocationManager()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(asb), name: .granted, object: nil)

        socket.event.message = { message in
            let data = (message as! String).data(using: .utf8)!
            do {
                self.bool = true
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                let currentVersion: Double = response.iosVersionNumber ?? -1.0
                if iosUpdateVersion < currentVersion {
                    errorGlobal = .newUpdateAvailable
                    self.performSegue(withIdentifier: "showError", sender: self)
                }
                if CLLocationManager.locationServicesEnabled() {
                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined, .restricted, .denied:
                        errorGlobal = .noGPS
                        self.performSegue(withIdentifier: "showError", sender: self)
                        return
                    default:
                        if currentUser() != nil {
                            if let savedOrder = orderFromUserDefaults() {
                                if let page: SavedPage = savedPage() {
                                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: page.rawValue) as? CatdimViewController {
                                        vc.order = savedOrder
                                        self.present(vc, animated: true)
                                    } else if let vc = self.storyboard?.instantiateViewController(withIdentifier: page.rawValue) as? BitdiViewController {
                                        vc.order = savedOrder
                                        self.present(vc, animated: true)
                                    } else if let vc = self.storyboard?.instantiateViewController(withIdentifier: page.rawValue) as? TamamlaViewController {
                                        vc.order = savedOrder
                                        self.present(vc, animated: true)
                                    } else if let vc = self.storyboard?.instantiateViewController(withIdentifier: page.rawValue) as? NewOrderViewController {
                                        vc.order = savedOrder
                                        self.present(vc, animated: true)
                                    } else {
                                        print("cannot instantiate controller with name:", page.rawValue)
                                    }
                                } else {
                                    print("Problem with page")
                                }
                            } else {
                                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "tab") {
                                    UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse], animations: {
                                        self.logoImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                                    }, completion: { (res) in
                                        self.present(vc, animated: true)
                                    })
                                }
                            }
                        } else {
                            self.performSegue(withIdentifier: "showLogin", sender: nil)
                        }
                    }
                }
            } catch {}
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        socket.close()
//        socket.op
        downloadUser()
    }
    //    override func viewWillDisappear(_ animated: Bool) {

    //
    //    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ErrorViewController {
            switch errorGlobal ?? .none {
            case .newUpdateAvailable:
                destination.message = newUpdateText
            case .noGPS:
                destination.message = noGPSText
            default:
                print("kklkdlfksldkflksdf")
            }
        }
    }

    @objc func reachabilityChanged() {
        switch socket.readyState {
        case .closed, .closing:
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "noInternet") as? NoInternetViewController {
                self.present(vc, animated: true)
            }
        default: break
        }
    }

}

extension RootViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if bool {
            switch status {
            case .authorizedAlways: fallthrough
            case .authorizedWhenInUse: print("56 Location status is OK.")
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "login") {
                self.present(vc, animated: true)
                }
            default: break
            }
        }
    }
}


