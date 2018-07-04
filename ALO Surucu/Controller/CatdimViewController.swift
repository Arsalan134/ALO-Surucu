//
//  CatdimViewController.swift
//  ALO Surucu
//
//  Created by Arsalan Iravani on 24.04.2018.
//  Copyright © 2018 Arsalan Iravani. All rights reserved.
//

import UIKit
import CoreLocation

class CatdimViewController: UIViewController {

    @IBOutlet weak var gozlemeLabel: UILabel!
    @IBOutlet weak var gedisLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var vaxtLabel: UILabel!

    @IBOutlet weak var catdimButton: UIButton!
    @IBOutlet weak var bitdiButton: UIButton!
    @IBOutlet weak var zengEtButton: UIButton!
    @IBOutlet weak var kordinatorButton: UIButton!

    var locationManager = CLLocationManager()

    var timer: Timer?
    var totalSecondsWaiting: Int = 0
    var status: StatusOfDriver = .none
    var start: Date?

    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()

        gozlemeLabel.text = order?.from
        gedisLabel.text = order?.to
        priceLabel.text = "\(order?.price ?? "-") azn"
        phoneLabel.text = order?.clientNumber
        locationManager.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .socketConnectionChanged, object: nil)

        saveToUserDefaults(order)
        saveToUserDefaults(.catdim)

        status = savedStatus() ?? .none
        start = loadTime()
        if start != nil {
            setTimeLabel()
        }
        setTitlesOfButton()

        socket.event.message = { message in
            let data = (message as! String).data(using: .utf8)!

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                switch response.url  {
                case "orders/moved":
                    clearOrderDefaults()
                    removeTime()
                    let alert = UIAlertController(title: "Imtina", message: "Sifariş imtina olunub.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "showTab", sender: self)
                    })
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                default: break
                }
            } catch {}
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeTime()
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

    func setTitlesOfButton() {
        switch status {
        case .none: break
//            catdimButton.setTitle("NONE", for: .normal)
        case .catmisam:
            catdimButton.setTitle("YOLDAYAM", for: .normal)
        case .yoldayam:
            catdimButton.setTitle("GÖZLƏYİRƏM", for: .normal)
        case .gozleyirem:
           catdimButton.setTitle("YOLDAYAM", for: .normal)
        }
    }

    @IBAction func catdimPressed() {
        switch status {
        case .none:
            // reached destination
            status = .catmisam
            start = Date()
            saveTime(start!)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
            guard let token = currentToken(), order != nil else {return}
            let request = ["url": "orders/status", "id": order?.id ?? "no id", "status": "reached", "username": currentUser()?.username ?? "no username", "token": token]
            socket.send(request.toJson())

        case .catmisam:
            // in the car and started to go
            status = .yoldayam
            guard start != nil else {
                print("Start is nil")
                return
            }

            let minutes = calculateTime(with: Int((start?.timeIntervalSinceNow)! * -1)).minutes
            if minutes > 20 {
                totalSecondsWaiting += 20 * 60 - Int((start?.timeIntervalSinceNow)! * -1)
            }
            timer?.invalidate()
            guard let token = currentToken(), order != nil else {return}
            let request = ["url": "orders/status", "id": order?.id ?? "no id", "status": "icra", "username": currentUser()?.username ?? "no username", "token": token]
            socket.send(request.toJson())

        case .yoldayam:
            // waiting
            status = .gozleyirem
            start = Date()
            saveTime(start!)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

        case .gozleyirem:
            status = .yoldayam
            timer?.invalidate()
            guard start != nil else {
                print("Start is nil")
                return
            }
            totalSecondsWaiting += Int((start?.timeIntervalSinceNow)! * -1)
        }

        saveToUserDefaults(status)
        setTitlesOfButton()
    }

    @objc func runTimedCode() {
        guard start != nil else {
            print("Start is nil")
            return
        }
        setTimeLabel()
//        print(time, totalSecondsWaiting)
    }

    func setTimeLabel() {
        let time = calculateTime(with: Int((start?.timeIntervalSinceNow)! * -1))
        DispatchQueue.main.async {
            let minutes =  String(format: "%02d", time.minutes)
            let seconds =  String(format: "%02d", time.seconds)
            self.vaxtLabel.text = "\(minutes):\(seconds)"
        }
    }

    @IBAction func bitdiPressed() {
        if let timer = timer {
            timer.invalidate()
            guard start != nil else {
                print("Start is nil")
                return
            }
            totalSecondsWaiting += Int((start?.timeIntervalSinceNow)! * -1)
        }
        clearDriverStatusFromUserDefaults()
        self.performSegue(withIdentifier: "bitdi", sender: self)
    }

    func calculateTime(with seconds: Int) -> (minutes: Int, seconds: Int) {
        let minutes = seconds / 60
        let secondsRest = seconds - minutes * 60
        return (minutes, secondsRest)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BitdiViewController {
            let minutes = Double(calculateTime(with: totalSecondsWaiting).minutes)
            let cerimePrice = minutes * 0.08
            order?.cerime = cerimePrice
            destination.order = order
//            print("Cerime is:", cerimePrice)
        }
    }

    @IBAction func callPressed(_ sender: UIButton) {
        // TODO: Phone number
        if sender.tag == 0 {
            guard let number = order?.clientNumber else {return}
            if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    // Fallback on earlier versions
                }
            }
        } else {
            guard let number = order?.coordinator else {return}
            if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}


extension CatdimViewController: CLLocationManagerDelegate {

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied, .notDetermined:
            print("3 Location is problem")
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "noGPS") as? ErrorViewController {
                vc.message = noGPSText
                self.present(vc, animated: true)
            }
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse: print("Location status is OK.")
        }
    }
}











